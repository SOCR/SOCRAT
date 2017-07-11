'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_powercalc_twoTest
  @type: service
  @desc: Performs two sample t test analysis
###


module.exports = class PowerCalcTwoTGUI extends BaseService
  @inject 'app_analysis_powerCalc_msgService',
    '$timeout'

  initialize: ->

    # dependecies
    @distribution = require 'distributome'
    @msgService = @app_analysis_powerCalc_msgService

    @distanceFromMean = 5
    @SIGNIFICANT = 5
    @populations = null
    @name = 'Two-sample t test (general case)'
    #variables needed for twoTest
    @twoTest = @app_analysis_powerCalc_twoTest
    @twoTestN1 = 10
    @twoTestN2 = 10
    @twoTestMaxN1 = 20
    @twoTestMaxN2 = 20
    @twoTestMaxN = 20
    @twoTestMean1 = 10
    @twoTestMean2 = 10
    @twoTestMeanMax1 = 20
    @twoTestMeanMax2 = 20
    @twoTestMeanMax = 20
    @twoTestSigma1 = 20
    @twoTestSigma2 = 20
    @twoTestSigmaMax1 = 40
    @twoTestSigmaMax2 = 40
    @twoTestSigmaMax = 40
    @twoTestAlpha = 0.010
    @twoTestPower = 0
    @twoTestPowerMax = 1
    @twoTestT = 0
    @twoTestPvalue = 0
    @compAgents = []
    @twoTestMode = "Two Tailed"
    @twoTestModes = ["Two Tailed", "One Tailed"]

    #data to observe
    @parameters =
      n1: @twoTestN1
      n2: @twoTestN2
      nMax: @twoTestMaxN
      mean1: @twoTestMean1
      mean2: @twoTestMean2
      meanMax: @twoTestMeanMax
      sigma1: @twoTestSigma1
      sigma2: @twoTestSigma2
      sigmaMax: @twoTestSigmaMax
      power: @twoTestPower
      t: @twoTestT
      pvl: @twoTestPvalue
      comp: @compAgents
      mode: @twoTestMode

    @twoTestUpdate()

  saveData: (data) ->
    @populations = data.populations
    if (data.chosenCol.length is 2)
      @compAgents = data.chosenCol
    else
      @compAgents = data.chosenVar
    @twoTestReceiveData()

  setAlpha: (alphaIn) ->
    @twoTestAlpha = alphaIn
    @twoTestUpdate()
    @twoTestCheckRange()
    return

  getName: () ->
    return @name

  getParams: () ->
    @parameters =
      n1: @twoTestN1
      n2: @twoTestN2
      nMax: @twoTestMaxN
      mean1: @twoTestMean1
      mean2: @twoTestMean2
      meanMax: @twoTestMeanMax
      sigma1: @twoTestSigma1
      sigma2: @twoTestSigma2
      sigmaMax: @twoTestSigmaMax
      power: @twoTestPower
      t: @twoTestT
      pvl: @twoTestPvalue
      comp: @compAgents
      mode: @twoTestMode

  setParams: (newParams) ->
    @twoTestN1 = newParams.n1
    @twoTestN2 = newParams.n2
    @twoTestMaxN = newParams.nMax
    @twoTestMean1 = newParams.mean1
    @twoTestMean2 = newParams.mean2
    @twoTestMeanMax = newParams.meanMax
    @twoTestSigma1 = newParams.sigma1
    @twoTestSigma2 = newParams.sigma2
    @twoTestSigmaMax = newParams.sigmaMax
    @twoTestPower = newParams.power
    @twoTestMode = newParams.mode
    @twoTestUpdate()
    return

  savePower: (newParams) ->
    @twoTestPower = newParams.power
    @twoTestMode = newParams.mode
    @twoTestPowerTon()
    return

  reset: () ->
    @twoTestN1 = 10
    @twoTestN2 = 10
    @twoTestMaxN1 = 20
    @twoTestMaxN2 = 20
    @twoTestMaxN = 20
    @twoTestMean1 = 10
    @twoTestMean2 = 10
    @twoTestMeanMax1 = 20
    @twoTestMeanMax2 = 20
    @twoTestMeanMax = 20
    @twoTestSigma1 = 20
    @twoTestSigma2 = 20
    @twoTestSigmaMax1 = 40
    @twoTestSigmaMax2 = 40
    @twoTestSigmaMax = 40
    @twoTestAlpha = 0.010
    @twoTestPower = 0
    @twoTestPowerMax = 1
    @twoTestT = 0
    @twoTestPvalue = 0
    @compAgents = []
    @twoTestMode = "Two Tailed"
    @twoTestUpdate()
    return

  twoTestReceiveData: () ->
    item1 = Object.keys(@populations)[0]
    item2 = Object.keys(@populations)[1]
    @twoTestN1 = @populations[item1].length
    @twoTestN2 = @populations[item2].length
    @twoTestMean1 = @getMean(@getSum(@populations[item1]),@populations[item1].length)
    @twoTestMean2 = @getMean(@getSum(@populations[item2]),@populations[item2].length)
    twoTestvariance1 = @getVariance(@populations[item1], @twoTestMean1)
    twoTestvariance2 = @getVariance(@populations[item2], @twoTestMean2)
    @twoTestSigma1 = Math.sqrt(twoTestvariance1)
    @twoTestSigma2 = Math.sqrt(twoTestvariance2)
    @twoTestCheckRange()
    @twoTestUpdate()
    return

  twoTestCheckRange:() ->
    @twoTestMaxN1 = Math.max(@twoTestN1, @twoTestMaxN1)
    @twoTestMaxN2 = Math.max(@twoTestN2, @twoTestMaxN2)
    @twoTestMaxN = Math.max(@twoTestMaxN1, @twoTestMaxN2)
    @twoTestMeanMax1 = Math.max(@twoTestMean1, @twoTestMeanMax1)
    @twoTestMeanMax2 = Math.max(@twoTestMean2, @twoTestMeanMax2)
    @twoTestMeanMax = Math.max(@twoTestMeanMax1, @twoTestMeanMax2)
    @twoTestSigmaMax1 = Math.max(@twoTestSigma1, @twoTestSigmaMax1)
    @twoTestSigmaMax2 = Math.max(@twoTestSigma2, @twoTestSigmaMax2)
    @twoTestSigmaMax = Math.max(@twoTestSigmaMax1, @twoTestSigmaMax2)

  twoTestUpdate: () ->
    twoTestvar1 = Math.pow(@twoTestSigma1,2)
    twoTestvar2 = Math.pow(@twoTestSigma2,2)
    kappa = @twoTestN1 / @twoTestN2
    # calculate power using different modes
    if @twoTestMode is "Two Tailed"
      z = (@twoTestMean1 - @twoTestMean2) / (Math.sqrt(twoTestvar1 + twoTestvar2) * Math.sqrt((1+(1 / kappa)) / @twoTestN2))
      @twoTestPower = @distribution.pnorm(z-@distribution.qnorm(1-@twoTestAlpha/2))+@distribution.pnorm(-z-@distribution.qnorm(1-@twoTestAlpha/2))
      @parameters.power = @twoTestPower
    else
      z = (@twoTestMean1 - @twoTestMean2) / Math.sqrt(twoTestvar1 + twoTestvar2 / kappa) * Math.sqrt(@twoTestN1)
      @twoTestPower = @distribution.pnorm(z-@distribution.qnorm(1-@twoTestAlpha))
      @parameters.power = @twoTestPower
    @twoTestTTest()
    @twoTestCheckRange()
    return

  twoTestPowerTon: () ->
    kappa = @twoTestN1 / @twoTestN2
    stdv = Math.sqrt(Math.pow(@twoTestSigma1,2) + Math.pow(@twoTestSigma2,2))
    twoTestvar1 = Math.pow(@twoTestSigma1,2)
    twoTestvar2 = Math.pow(@twoTestSigma2,2)
    # calculate n1 or n2 from power based on different mdoes
    if @twoTestMode is "Two Tailed"
      @twoTestN2 = (1 + 1 / kappa)*Math.pow(stdv*(@distribution.qnorm(1-@twoTestAlpha / 2)+@distribution.qnorm(@twoTestPower))/(@twoTestMean1-@twoTestMean2),2)
      @twoTestN2 = Math.round(@twoTestN2)
      @twoTestMaxN2 = Math.max(@twoTestMaxN2, @twoTestN2)
      # @parameters.n2 = @twoTestn2
    else
      @twoTestN1=(twoTestvar1 + twoTestvar2 / kappa) * Math.pow((@distribution.qnorm(1-@twoTestAlpha)+@distribution.qnorm(@twoTestPower))/(@twoTestMean1-@twoTestMean2),2)
      @twoTestN1 = Math.round(@twoTestN1)
      @twoTestMaxN2 = Math.max(@twoTestMaxN1, @twoTestN1)
      # @parameters.n1 = @twoTestn1
    @twoTestCheckRange()
    @twoTestTTest()
    return

  twoTestTTest: () ->
    v1 = Math.pow(@twoTestSigma1,2) / @twoTestN1
    v2 = Math.pow(@twoTestSigma2,2) / @twoTestN2
    df =  Math.round(Math.pow((v1 + v2),2) / (Math.pow(v1,2) / (@twoTestN1 - 1.0) + Math.pow(v2,2) / (@twoTestN2 - 1.0)))
    @twoTestT = (@twoTestMean1 - @twoTestMean2) / (Math.sqrt(v1 + v2))
    @twoTestPvalue = 1 - @tProb(df, @twoTestT)
    @twoTestPvalue *= 2 if @twoTestMode is 'Two Tailed'
    @twoTestPvalue = Math.max(0, @twoTestPvalue)
    @twoTestPvalue = Math.min(1, @twoTestPvalue)

  extract: (data, variable) ->
    tmp = []
    for d in data
      tmp.push +d[variable]
    tmp

  getRightBound: (middle,step) ->
    return middle + step * @distanceFromMean

  getLeftBound: (middle,step) ->
    return middle - step * @distanceFromMean

  sort: (values) ->
    values.sort (a, b) -> a-b

  getVariance: (values, mean) ->
    temp = 0
    numberOfValues = values.length
    while( numberOfValues--)
      temp += Math.pow( (parseInt(values[numberOfValues]) - mean), 2 )

    return temp / values.length

  getSum: (values) ->
    values.reduce (previousValue, currentValue) -> parseFloat(previousValue) + parseFloat(currentValue)

  getGaussianFunctionPoints: (mean, std, leftBound, rightBound) ->
    data = []
    for i in [leftBound...rightBound]
      data.push
        x: i
        y: (1 / (std * Math.sqrt(Math.PI * 2))) * Math.exp(-(Math.pow(i - mean, 2) / (2 * Math.pow(std, 2))))
    data

  getMean: (valueSum, numberOfOccurrences) ->
    valueSum / numberOfOccurrences

  getZ: (x, mean, standardDerivation) ->
    (x - mean) / standardDerivation

  getWeightedValues: (values) ->
    weightedValues= {}
    data= []
    lengthValues = values.length
    for i in [0...lengthValues] by 1
      label = values[i].toString()
      if(weightedValues[label])
        weightedValues[label].weight++
      else
        weightedValues[label]={weight :1,value :label}
        data.push(weightedValues[label])
    return data

  getRandomNumber: (min,max) ->
    Math.round((max-min) * Math.random() + min)

  getRandomValueArray: (data) ->
    values = []
    length = data.length
    for i in [1...length]
      values.push data[Math.floor(Math.random() * data.length)]
    return values

  getChartData: () ->
    mean1 = @twoTestMean1
    stdDev1 = @twoTestSigma1
    mean2 = @twoTestMean2
    stdDev2 = @twoTestSigma2
    alpha = @twoTestAlpha

    rightBound = Math.max(@getRightBound(mean1, stdDev1), @getRightBound(mean2, stdDev2))
    leftBound = Math.min(@getLeftBound(mean1, stdDev1), @getLeftBound(mean2, stdDev2))
    bottomBound = 0
    topBound = Math.max(1 / (stdDev1 * Math.sqrt(Math.PI * 2)), 1 / (stdDev2 * Math.sqrt(Math.PI * 2)))
    gaussianCurveData1 = @getGaussianFunctionPoints(mean1, stdDev1,leftBound,rightBound)
    gaussianCurveData2 = @getGaussianFunctionPoints(mean2, stdDev2,leftBound,rightBound)

    bounds =
      left: leftBound
      right: rightBound
      top: topBound
      bottom: bottomBound

    data = [gaussianCurveData1, gaussianCurveData2]

    return {
      data: data
      bounds: bounds
    }

  tProb: ($n, $x) ->
    if $n <= 0
      throw 'Invalid n: $n\n'
      ### degree of freedom ###
    @precisionString @subTProb($n - 0, $x - 0)

  integer: ($i) ->
    if $i > 0
      Math.floor $i
    else
      Math.ceil $i

  precisionString: ($x) ->
    if $x
      @roundToPrecision $x, @precision($x)
    else
      '0'

  roundToPrecision: ($x, $p) ->
    $x = $x * 10 ** $p
    $x = Math.round($x)
    $x / 10 ** $p

  precision: ($x) ->
    Math.abs @integer(@log10(Math.abs($x)) - @SIGNIFICANT)

  subTProb: ($n, $x) ->
    $a = undefined
    $b = undefined
    $w = Math.atan2($x / Math.sqrt($n), 1)
    $z = Math.cos($w) ** 2
    $y = 1
    $i = $n - 2
    while $i >= 2
      $y = 1 + ($i - 1) / $i * $z * $y
      $i -= 2
    if $n % 2 == 0
      $a = Math.sin($w) / 2
      $b = .5
    else
      $a = if $n == 1 then 0 else Math.sin($w) * Math.cos($w) / Math.PI
      $b = .5 + $w / Math.PI
    @max 0, 1 - $b - ($a * $y)

  log10: ($n) ->
    Math.log($n) / Math.log(10)

  max: () ->
    $max = arguments[0]
    $i = 0
    while $i < arguments.length
      if $max < arguments[$i]
        $max = arguments[$i]
      $i++
    $max

  tDistr: ($n, $p) ->
    if $n <= 0
      throw 'Invalid n: $n\n'
    if $p <= 0 or $p >= 1
      throw 'Invalid p: $p\n'
    @precisionString @subT($n - 0, $p - 0)

  subT: ($n, $p) ->
    if $p >= 1 or $p <= 0
      throw 'Invalid p: $p\n'
    if $p == 0.5
      return 0
    else if $p < 0.5
      return -@subT($n, 1 - $p)
    $u = @subU($p)
    $u2 = $u ** 2
    $a = ($u2 + 1) / 4
    $b = ((5 * $u2 + 16) * $u2 + 3) / 96
    $c = (((3 * $u2 + 19) * $u2 + 17) * $u2 - 15) / 384
    $d = ((((79 * $u2 + 776) * $u2 + 1482) * $u2 - 1920) * $u2 - 945) / 92160
    $e = (((((27 * $u2 + 339) * $u2 + 930) * $u2 - 1782) * $u2 - 765) * $u2 + 17955) / 368640
    $x = $u * (1 + ($a + ($b + ($c + ($d + $e / $n) / $n) / $n) / $n) / $n)
    if $n <= @log10($p) ** 2 + 3
      $round = undefined
      loop
        $p1 = @subTProb($n, $x)
        $n1 = $n + 1
        $delta = ($p1 - $p) / Math.exp(($n1 * Math.log($n1 / ($n + $x * $x)) + Math.log($n / $n1 / 2 / Math.PI) - 1 + (1 / $n1 - (1 / $n)) / 6) / 2)
        $x += $delta
        $round = @roundToPrecision($delta, Math.abs(@integer(@log10(Math.abs($x)) - 4)))
        unless $x and $round != 0
          break
    $x

  subU: ($p) ->
    $y = -Math.log(4 * $p * (1 - $p))
    $x = Math.sqrt($y * (1.570796288 + $y * (.03706987906 + $y * (-.8364353589e-3 + $y * (-.2250947176e-3 + $y * (.6841218299e-5 + $y * (0.5824238515e-5 + $y * (-.104527497e-5 + $y * (.8360937017e-7 + $y * (-.3231081277e-8 + $y * (.3657763036e-10 + $y * .6936233982e-12)))))))))))
    if $p > .5
      $x = -$x
    $x
