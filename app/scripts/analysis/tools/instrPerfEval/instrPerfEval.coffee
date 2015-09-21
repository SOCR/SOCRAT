'use strict'

instrPerfEval = angular.module('app_analysis_instrPerfEval', [])

.factory('app_analysis_instrPerfEval_constructor', [
    'app_analysis_instrPerfEval_manager'
    (manager) ->
      (sb) ->

        manager.setSb sb unless !sb?
        _msgList = manager.getMsgList()

        init: (opt) ->
          console.log 'instrPerfEval init invoked'

        destroy: () ->

        msgList: _msgList
  ])

.factory('app_analysis_instrPerfEval_manager', [
    () ->
      _sb = null

      _msgList =
        outgoing: ['get table']
        incoming: ['take table']
        scope: ['instrPerfEval']

      _setSb = (sb) ->
        _sb = sb

      _getSb = () ->
        _sb

      _getMsgList = () ->
        _msgList

      getSb: _getSb
      setSb: _setSb
      getMsgList: _getMsgList
  ])

.controller('instrPerfEvalMainCtrl', [
    'app_analysis_instrPerfEval_manager'
    'app_analysis_instrPerfEval_alphaCalculator'
    '$scope'
    (ctrlMngr, alphaCalculator, $scope) ->
      console.log 'instrPerfEvalViewMainCtrl executed'

      prettifyArrayOutput = (arr) ->
        if arr?
          arr = arr.map (x) -> x.toFixed 3
          '[' + arr.toString().split(',').join('; ') + ']'

      data = alphaCalculator.getAlpha()

      $scope.cronAlpha = Number(data.cronAlpha).toFixed(3)
      $scope.icc = Number(data.icc).toFixed(3)
      $scope.kr20 = if data.kr20 is 'Not a binary data' then data.kr20 else Number(data.kr20).toFixed(3)
      $scope.cronAlphaIdInterval = prettifyArrayOutput(data.idIntervals)
      $scope.cronAlphaKfInterval = prettifyArrayOutput(data.kfIntervals)
      $scope.cronAlphaLogInterval = prettifyArrayOutput(data.logitIntervals)
      $scope.splitHalfCoef = Number(data.adjRCorrCoef).toFixed(3)
  ])

.controller('instrPerfEvalSidebarCtrl', [
    'app_analysis_instrPerfEval_manager'
    'app_analysis_instrPerfEval_alphaCalculator'
    '$scope'
    '$stateParams'
    '$q'
    (ctrlMngr, alphaCalculator, $scope, $stateParams, $q) ->
      console.log 'instrPerfEvalViewSidebarCtrl executed'

      sb = ctrlMngr.getSb()

      $scope.nCols = '5'
      $scope.nRows = '5'

      deferred = $q.defer()

      $scope.confLevel = 0.95

      # subscribe for incoming message with data
      token = sb.subscribe
        msg: 'take table'
        msgScope: ['instrPerfEval']
        listener: (msg, data) ->
          _data = data
          $scope.nRows = _data.data?.length
          $scope.nCols = _data.data[0]?.length
          console.log data
          alphaCalculator.calculate data, $scope.confLevel

      sb.publish
        msg: 'get table'
        msgScope: ['instrPerfEval']
        callback: -> sb.unsubscribe token
        data:
          tableName: $stateParams.projectId + ':' + $stateParams.forkId
          promise: deferred
  ])

.factory('app_analysis_instrPerfEval_alphaCalculator', [
  () ->

    _data = []

    _getAlpha = ->
      _data

    _getCAlpha = (matrix) ->
      k = jStat.cols matrix
      # calculate Cronbach's Alpha
      sumColsVar = jStat.sum matrix.variance()
      rowTotalsVar = jStat.variance matrix.transpose().sum()
      cAlpha = (k / (k - 1)) * (1 - sumColsVar / rowTotalsVar)

    _getCAlphaConfIntervals = (matrix, cAlpha, gamma) ->
      k = jStat.cols matrix
      r = jStat.rows matrix

      # calculate ID confidence intervals
      omega = 2 * (k - 1) * (1 - cAlpha) / k
      varCapAlphaCap = (k * k * omega) / (r * (k - 1) * (k - 1))
      idIntervalAbsDev = jStat.normal.inv(1 - gamma / 2, 0, 1) * Math.sqrt(varCapAlphaCap)
      idIntervalLeft = cAlpha - idIntervalAbsDev
      idIntervalRight = cAlpha + idIntervalAbsDev

      # calculate KF confidence intervals
      kfIntervalLeft = 1 - (1 - cAlpha) * Math.exp jStat.normal.inv(1 - gamma / 2, 0, 1) *
          Math.sqrt 2 * k / (r * (k - 1))
      kfIntervalRight = 1 - (1 - cAlpha) * Math.exp -1 * jStat.normal.inv(1 - gamma / 2, 0, 1) *
          Math.sqrt 2 * k / (r * (k - 1))

      #calculate logit confidence intervals
      thetaCap = Math.log(cAlpha / (1 - cAlpha))
      varCapThetaCap = varCapAlphaCap * Math.pow(1 / cAlpha + 1 / (1 - cAlpha), 2)
      thetaAbsDev = jStat.normal.inv(1 - gamma / 2, 0, 1) * Math.sqrt(varCapThetaCap)
      thetaIntervalLeft = thetaCap - thetaAbsDev
      thetaIntervalRight = thetaCap + thetaAbsDev
      logitIntervalLeft = Math.exp(thetaIntervalLeft) / (1 + Math.exp(thetaIntervalLeft))
      logitIntervalRight = Math.exp(thetaIntervalRight) / (1 + Math.exp(thetaIntervalRight))

      _cAlphaConfIntervals =
        idIntervals: [Math.max(0, idIntervalLeft), Math.min(1, idIntervalRight)]
        kfIntervals: [Math.max(0, kfIntervalLeft), Math.min(1, kfIntervalRight)]
        logitIntervals: [Math.max(0, logitIntervalLeft), Math.min(1, logitIntervalRight)]

    _getIcc = (matrix) ->
      # Intraclass correlation coefficient
      #  https://en.wikipedia.org/wiki/Intraclass_correlation#Modern_ICC_definitions:_simpler_formula_but_positive_bias
      #  http://www.real-statistics.com/reliability/intraclass-correlation/
      #  http://statwiki.ucdavis.edu/Statistical_Computing/Analysis_of_Variance/Two-Factor_ANOVA_model_with_n_%3D_1_(no_replication)
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

    _getSpliHalfReliability = (matrix) ->
      # Split-Half Reliability coefficient
      #  http://www.real-statistics.com/reliability/split-half-methodology/
      #  https://en.wikipedia.org/wiki/Spearman–Brown prediction formula

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

    _getKr20 = (matrix) ->
      # Calculating Kuder–Richardson Formula 20 (KR-20)
      zeroMatrix = matrix.subtract 1
      if jStat.sum(jStat(zeroMatrix).sum()) isnt 0
        kr20 = 'Not a binary data'

    _calculate = (obj, confLevel) ->
      _matrix = jStat obj.data
      _matrix = jStat jStat.map _matrix, Number

      # Calculate confidence intervals
      _gamma = (1 - confLevel) * 2 # confidence coefficient
      _cAlpha = _getCAlpha(_matrix)
      _cAlphaConfIntervals = _getCAlphaConfIntervals(_matrix, _cAlpha, _gamma)

      _data =
        cronAlpha: _cAlpha
        icc: _getIcc(_matrix)
        kr20: _getKr20(_matrix)
        adjRCorrCoef: _getSpliHalfReliability(_matrix)
        idIntervals: _cAlphaConfIntervals.idIntervals
        kfIntervals: _cAlphaConfIntervals.kfIntervals
        logitIntervals: _cAlphaConfIntervals.logitIntervals

    calculate: _calculate
    getAlpha: _getAlpha
])