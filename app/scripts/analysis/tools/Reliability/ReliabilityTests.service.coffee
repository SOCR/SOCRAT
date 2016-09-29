'use strict'

jStat = require 'jstat'
BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

# Confidence intervals for Crobach's Alpha
#  1. TSAGRIS, MICHAIL, CONSTANTINOS C. FRANGOS, and CHRISTOS C. FRANGOS.
#   "Confidence intervals for Cronbach’s reliability coefficient."
#   http://www.wseas.us/e-library/conferences/2013/Vouliagmeni/CCC/CCC-25.pdf
#  2. Maydeu-Olivares, Alberto, Donna L. Coffman, and Wolfgang M. Hartmann.
#   "Asymptotically distribution-free (ADF) interval estimation of coefficient alpha."
#   Psychological methods 12.2 (2007): 157.
#   http://www.ub.edu/gdne/amaydeusp_archivos/ADF%20CIs%20for%20alpha%20PM07.pdf

module.exports = class ReliabilityTests extends BaseModuleDataService

  initialize: ->

    @metrics = [
      name: "Cronbach's Alpha"
      method: @cAlphaAndConfIntervals
    ,
      name: 'Intraclass correlation coefficient'
      method: @icc
    ,
      name: 'Split-Half Reliability coefficient'
      method: @splitHalfReliability
    ,
      name: 'Kuder–Richardson Formula 20 (KR-20)'
      method: @kr20
    ]

  cAlphaAndConfIntervals: (data, confLevel) ->
    matrix = jStat data
    matrix = jStat jStat.map matrix, Number
    @gamma = (1 - confLevel) * 2 # confidence coefficient

  cronbachAlpha: (matrix) ->
    matrix = jStat(matrix)
    k = jStat.cols matrix
    # calculate Cronbach's Alpha
    sumColsVar = jStat.sum matrix.variance()
    rowTotalsVar = jStat.variance matrix.transpose().sum()
    cAlpha = (k / (k - 1)) * (1 - sumColsVar / rowTotalsVar)

  cronbachAlphaConfIntervals: () ->
    matrix = jStat(matrix)
    k = jStat.cols matrix
    r = jStat.rows matrix

    # calculate covariance matrix
    matrixSquared = jStat.create k, (i, j) -> return 0
    for row, i in matrix.transpose()
      for col, j in matrix.transpose()
        matrixSquared[i][j] = (a * col[l] for l, a of row).reduce (t, s) -> t + s
    colMeans = matrix.mean() # row vector
    colMeansSquared = jStat.create k, (i, j) -> return 0
    for i in [0..k-1]
      for j in [0..k-1]
        colMeansSquared[i][j] = colMeans[i] * colMeans[j] * r
    cov = jStat.create k, (i, j) -> return 0
    covSum = 0
    covDiagSum = 0
    for i in [0..k-1]
      for j in [0..k-1]
        cov[i][j] = (matrixSquared[i][j] - colMeansSquared[i][j]) * (1 / (r - 1))
        covSum = covSum + cov[i][j]
        covDiagSum = covDiagSum + cov[i][j] if i == j
    covOffDiagSum = (covSum - covDiagSum) / 2

  # asymptotically distribution-free (ADF) interval
  cAplhaAdfConfInterval: () ->
    # calculate ADF confidence intervals
    dwrtvar = -2 * (k / (k - 1)) * covOffDiagSum / (covSum * covSum)
    dwrtcov = (k / (k - 1)) * covOffDiagSum / (covSum * covSum)
    jac = jStat.create k, (i, j) -> return dwrtcov
    for j in [0..k - 1]
      jac[j][j] = dwrtvar

    trac = 0
    for isub in [0..r - 1]
      v = jStat(matrix).row(isub)[0].map (x, i) -> x - colMeans[i] # row vector
      wcv = jStat.create k, (i, j) -> return 0
      wcvSum = 0
      for i in [0..k-1]
        for j in [0..k-1]
          wcv[i][j] = jac[i][j] * (v[i] * v[j] - cov[i][j])
          wcvSum = wcvSum + wcv[i][j]
      trac = trac + wcvSum * wcvSum
    nnase = Math.sqrt((1 / r) * (1 / (r - 1)) * trac)
    adfIntervalLeft = cAlpha - jStat.normal.inv(1 - gamma / 2, 0, 1) * nnase
    adfIntervalRight = cAlpha + jStat.normal.inv(1 - gamma / 2, 0, 1) * nnase
    [Math.max(0, adfIntervalLeft), Math.min(1, adfIntervalRight)]

  # ID confidence interval
  cAplhaIdConfInterval: () ->
    omega = 2 * (k - 1) * (1 - cAlpha) / k
    varCapAlphaCap = (k * k * omega) / (r * (k - 1) * (k - 1))
    idIntervalAbsDev = jStat.normal.inv(1 - gamma / 2, 0, 1) * Math.sqrt(varCapAlphaCap)
    idIntervalLeft = cAlpha - idIntervalAbsDev
    idIntervalRight = cAlpha + idIntervalAbsDev
    [Math.max(0, idIntervalLeft), Math.min(1, idIntervalRight)]

  # Koning and Franses confidence interval
  cAlphaKfConfInterval: () ->
    kfIntervalLeft = 1 - (1 - cAlpha) * Math.exp jStat.normal.inv(1 - gamma / 2, 0, 1) *
        Math.sqrt 2 * k / (r * (k - 1))
    kfIntervalRight = 1 - (1 - cAlpha) * Math.exp -1 * jStat.normal.inv(1 - gamma / 2, 0, 1) *
        Math.sqrt 2 * k / (r * (k - 1))
    [Math.max(0, kfIntervalLeft), Math.min(1, kfIntervalRight)]

  # bootstrap confidence intervals
  cAlphaBootstrapConfInterval: () ->
    #  calculate acceleration term using Jackknife
    alphaCapIthDeleted = []
    for idx in [0..r - 1] # get sample estimates when Ith row is deleted
      rowsBeforeIdx = matrix.slice 0, idx
      rowsAfterIdx = matrix.slice idx + 1
      matrixWithoutIdxRow = rowsBeforeIdx.concat rowsAfterIdx
      alphaCapIthDeleted.push(_getCAlpha matrixWithoutIdxRow)
    alphaCapJackknife = (alphaCapIthDeleted.reduce (t, s) -> t + s) / r
    accelAlphaNum = (alphaCapIthDeleted.map (x) -> x - alphaCapJackknife).map (x) -> Math.pow(x, 3)
    accelAlphaNum = accelAlphaNum.reduce (t, s) -> t + s
    accelAlphaDenom = (alphaCapIthDeleted.map (x) -> x - alphaCapJackknife).map (x) -> Math.pow(x, 2)
    accelAlphaDenom = 6 * Math.pow((accelAlphaDenom.reduce (t, s) -> t + s), 3/2)
    accelerationAlpha = accelAlphaNum / accelAlphaDenom

    # calculate bias correction using bootstrapping
    B = 1000 # number of bootstrap samples
    alphaBootstrapped = [] # bootstrap sample estimates
    for sample in [0..B - 1]
      sampleMatrix = []
      for idx in [0..r - 1]
        newRowIdx = Math.floor(Math.random() * r)
        sampleMatrix.push(matrix[newRowIdx])
      alphaBootstrapped.push(_getCAlpha(sampleMatrix))
    smallerAlphas = (val for val in alphaBootstrapped when val < cAlpha)
    zCapZero = jStat.normal.inv(smallerAlphas.length / B, 0, 1)

    # calculate gammas for interval
    gamma1Num = zCapZero + jStat.normal.inv(gamma / 2, 0, 1)
    gamma1Denom =1 - cAlpha * (zCapZero + jStat.normal.inv(gamma / 2, 0, 1))
    gamma1 = jStat.normal.cdf(zCapZero + gamma1Num / gamma1Denom, 0, 1)
    gamma2Num = zCapZero + jStat.normal.inv(1 - gamma / 2, 0, 1)
    gamma2Denom = 1 - cAlpha * (zCapZero + jStat.normal.inv(1 - gamma / 2, 0, 1))
    gamma2 = jStat.normal.cdf(zCapZero + gamma2Num / gamma2Denom, 0, 1)
    bootstrapPercentiles = [jStat.percentile(alphaBootstrapped, gamma1), jStat.percentile(alphaBootstrapped, gamma2)]
    bootstrapPercentiles = bootstrapPercentiles.sort()

    [Math.max(0, bootstrapPercentiles[0]), Math.min(1, bootstrapPercentiles[1])]

  # calculate logit confidence intervals
  cAlphaLogitConfInterval: () ->
    thetaCap = Math.log(cAlpha / (1 - cAlpha))
    varCapThetaCap = varCapAlphaCap * Math.pow(1 / cAlpha + 1 / (1 - cAlpha), 2)
    thetaAbsDev = jStat.normal.inv(1 - gamma / 2, 0, 1) * Math.sqrt(varCapThetaCap)
    thetaIntervalLeft = thetaCap - thetaAbsDev
    thetaIntervalRight = thetaCap + thetaAbsDev
    logitIntervalLeft = Math.exp(thetaIntervalLeft) / (1 + Math.exp(thetaIntervalLeft))
    logitIntervalRight = Math.exp(thetaIntervalRight) / (1 + Math.exp(thetaIntervalRight))
    [Math.max(0, logitIntervalLeft), Math.min(1, logitIntervalRight)]

  # Intraclass correlation coefficient
  #  https://en.wikipedia.org/wiki/Intraclass_correlation#Modern_ICC_definitions:_simpler_formula_but_positive_bias
  #  http://www.real-statistics.com/reliability/intraclass-correlation/
  #  http://statwiki.ucdavis.edu/Statistical_Computing/Analysis_of_Variance/Two-Factor_ANOVA_model_with_n_%3D_1_(no_replication)
  icc: (matrix) ->
    matrix = jStat(matrix)
    k = jStat.cols matrix
    r = jStat.rows matrix

    # Find 2-way ANOVA coefficients
    matrixMean = jStat.sum(matrix.sum()) / (r * k)  # estimated overall mean
    rowMeans = matrix.transpose().mean() # [mean xi]
    colMeans = matrix.mean() # [mean xj]
    ssRows = k * jStat.sum jStat.pow(jStat.subtract(rowMeans, matrixMean), 2)
    ssCols = r * jStat.sum jStat.pow(jStat.subtract(colMeans, matrixMean), 2)
    ssErr = 0
    for row, i in matrix
      for ij, j in row
        ssErr = ssErr + Math.pow(ij - rowMeans[i] - colMeans[j] + matrixMean, 2)
    msRows = ssRows / (r - 1)
    msCols = ssCols / (k - 1)
    msErr = ssErr / ((r - 1) * (k - 1))
    # Calculate Intraclass Correlation Coefficient
    icc = ((msRows - msErr) / k) / ((msRows - msErr) / k + (msCols - msErr) / r + msErr)

  # Split-Half Reliability coefficient
  #  http://www.real-statistics.com/reliability/split-half-methodology/
  #  https://en.wikipedia.org/wiki/Spearman–Brown prediction formula
  splitHalfReliability: () ->
    matrix = jStat(matrix)
    k = jStat.cols matrix
    r = jStat.rows matrix

    nGroups = 2
    oddSum = jStat.zeros(1, r)[0]
    evenSum = jStat.zeros(1, r)[0]
    for col in matrix.transpose() by 2
      evenSum = (evenSum[x] + col[x] for x of evenSum)
    for colIdx in [1..k-1] by 2
      col = jStat.transpose jStat.col(matrix, colIdx)
      oddSum = (oddSum[x] + col[x] for x of oddSum)
    meanOdd = jStat.mean oddSum
    meanEven = jStat.mean evenSum
    rCorrCoef = jStat.corrcoeff oddSum, evenSum
    adjRCorrCoef = rCorrCoef * nGroups / (1 + (nGroups - 1) * rCorrCoef)

  # Calculating Kuder–Richardson Formula 20 (KR-20)
  # TODO: finish calculations
  kr20: (matrix) ->
    matrix = jStat(matrix)
    zeroMatrix = matrix.subtract 1
    if jStat.sum(jStat(zeroMatrix).sum()) isnt 0
      kr20 = 'Not a binary data'
