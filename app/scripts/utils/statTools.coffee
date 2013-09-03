statTools = angular.module "socr.statTools",[]

statTools.service "lookup", ->
  #hash map for all the available statTools
  # or it can go into the database

statTools.provider "KStest", ->
  #constants
  alpha = 0.05
  SEQUENCE_STEPS = 500
  significanceLevel = 0.05

  #meta data
  type = "test"
  name = "KolmogorovSmirnoff"
  test = {}


  ###
    ferguson's code
  ###
  _lcm = (m,n)->
    mn = m * n
    while (m > 0)
      k = n % m
      n = m
      m = k
    return mn / n

  _smircdf = (d,m,n)->
    c = m * n * d + .0000001
    #System.out.println("smircdf c = " + c)
    u = new Array(n+2)
    u[0]=1
    j = 0
    i = 0
    while i < n
      j = i + 1
      if (m*j>c)
        u[i+1]=0
      else
        u[i+1]=1
      i++
    i = 0
    while i < m
      j = i + 1
      w = j / (j + n)
      if n * i > c
        u[0] = 0
      else
        u[0] = w * u[0]
      k = 0
      while k < n
        if Math.abs(n * i - m * k) > c
          u[k + 1] = 0
        else
          u[k + 1] = u[k] + u[k + 1] * w
        k++
      i++
    u[n]

  _kolsmir = (z)->
    ks = 0.5
    i = 0
    if z > .27
      ks = 0
      y = -2 * z * z
      i = 27
      while i >= 1
        ks = Math.exp(i * y) * (1 - ks)
        i = i - 2
    1 - 2 * ks
  

  _computeProb = (m, n, x) ->
    klcm = _lcm(m, n)
    d = Math.floor(x * klcm) / klcm
    if x <= 0
      prob = 0
    else if x >= 1
      prob = 1
    else if m > n
      prob = _smircdf(d, n, m)
    else
      prob = _smircdf(d, m, n)
    z = 0
    if m is n
      z = Math.sqrt(m * n / (m + n)) * (d + 1 / m)
    else
      z = Math.sqrt(m * n / (m + n)) * (d + 1 / (m + n))
    # appr = _kolsmir(z)
    prob

    # need to figure out its purpose
  _getStepArray = (length)->
    output = new Array(length + 1)
    i = 1
    while i < output.length
      output[i] = output[i - 1] + 1 / length
      i++
    output

  _increaseXElement = (input)->
    output = new Array(input.length + 1)
    i = 0
    while i < input.length
      output[i] = input[i]
      i++
    output[output.length - 1] = output[output.length - 2] + 1
    output

  _increaseYElement = (input)->
    output = new Array(input.length + 1)
    i = 0
    while i < input.length
      output[i] = input[i]
      i++
    output[output.length - 1] = 1
    output
  
   _makeSequence =( min, max, inc...)->
    if inc?
      inc = (max - min) / SEQUENCE_STEPS
    amount = (max - min) / inc
    step = Math.ceil(amount)
    seq = new Array step
    seq[0] = min
    i = 1
    while i < seq.length
      seq[i] = seq[0] + i * inc
      i++
    return seq
  
  _getCDFValue = (xseries, x, y)->
    index = 0
    size = xseries.length
    currentIndex
    i = 0
    while i < size - 1
      if xseries[i] <= x and x < xseries[i + 1]
        index = i + 1
        break
      i++

    if (x >= xseries[size - 1])
      index = size
    answer = y[index]

  _findDStatistic = ( x1, ystep1, x2, ystep2)->
    commonMax = Math.ceil _.max([_.max(x1), _.max(x2)])
    commonMin = Math.floor _.min([_.min(x1), _.min(x2)])
    seq = _makeSequence commonMin, commonMax
    length = seq.length
    z1 = new Array length
    z2 = new Array length
    diff = new Array length
    absDiff = new Array length
    i = 0
    while i < length
      z1[i] = _getCDFValue x1, seq[i], ystep1
      z2[i] = _getCDFValue x2, seq[i], ystep2
      diff[i] = z1[i] - z2[i]
      absDiff[i] = Math.abs diff[i]
      i++
    _.max absDiff


    
  ###
    Test Object is to be returned. Public methods.
  ###
    
  test.analyze = (data)->
    #get x and y data
    test.getKSResult(x,y)

  
  test.findKolmogorovProb=(z)->
    maxStep = 1000
    p = 0
    j = 1
    while j<=maxStep
      onePower = (j%2 ==0) ? -1:1
      p+=onePower*Math.exp(-s*j*j*z*z)
    
      j++
    p*=2
    p
  test.getKSResult = (x1,x2)->
    x1 = _.sort x1, (num)->
      num
    x2 = _.sort x2, (num)->
      num

    size1 = x1.length
    size2 = x2.length

    ystep1 = _getStepArray size1
    ystep2 = _getStepArray size2


    max1 = x1[x1.length - 1]
    min1 = x1[0]
    max2 = x2[x2.length - 1]
    min2 = x2[0]
    #get the step values

    #if there is intersection
    if max1 > min2 and max2 > min1
      dStat = _findDstatistic x1, ystep1, x2, ystep2
      z = 0
      if size1 == size2
        #z=Math.sqrt(m*n/(m+n))*(d+1/m)
        z = Math.sqrt(size1*size2/(size1+size2))*(dStat + 1/size1)
        zFormula = "z = sqrt(m*n/(m+n))*(d+1/m)"

      else
        #z=Math.sqrt(m*n/(m+n))*(d+1/(m+n))
        z = Math.sqrt(size1*size2/(size1+size2))*(dStat + 1/(size1 + size2))
        zFormula = "z = sqrt(m*n/(m+n))*(d+1/(m+n))"

      prob = _computeProb(size1, size2, dStat)
    else
      dStat = -1
  
  this.$get = ->
    test

# Algo @ http://www.itl.nist.gov/div898/software/dataplot/
# refman2/auxillar/quantile.htm
statTools.factory 'quantileArray', ->
  (input)->
    if !input?
      return false
    total = 100
    qPercent = 0
    factor = 0.01
    w = []
    n = input.length
    result = []
    result[0] = input[0]
    result[total] = input[n-1]

    input = input.sort()
    for i in [1..total] by 1
      qPercent = i * factor
      a = (n+1)*qPercent - 1
      b = (n+1) - (1 - qPercent) - 1
      temp = 0
      for j in [1..n] by 1
        betad = new BetaDistribution(a, b)
        w[i] = betad.CDF((i+1)/n) - betad.CDF(i/n)
        temp = temp + w[i] * input[i]

      result[i] = temp
      temp = 0
    result
  