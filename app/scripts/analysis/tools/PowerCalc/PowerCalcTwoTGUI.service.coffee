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
    @twoTestn1 = 10
    @twoTestn2 = 10
    @twoTestmaxn1 = 20
    @twoTestmaxn2 = 20
    @twoTestmaxn = 20
    @twoTestmean1 = 10
    @twoTestmean2 = 10
    @twoTestmeanMax1 = 20
    @twoTestmeanMax2 = 20
    @twoTestmeanMax = 20
    @twoTestsigma1 = 20
    @twoTestsigma2 = 20
    @twoTestsigmaMax1 = 40
    @twoTestsigmaMax2 = 40
    @twoTestsigmaMax = 40
    @twoTestalpha = 0.010
    @twoTestpower = 0
    @twoTestpowerMax = 1
    @twoTestt = 0
    @twoTestpvalue = 0
    @comp_agents = []
    @twoTestmode = "Two Tailed"
    @twoTestmodes = ["Two Tailed", "One Tailed"]

    #data to observe
    @parameters =
      n1: @twoTestn1
      n2: @twoTestn2
      nMax: @twoTestmaxn
      mean1: @twoTestmean1
      mean2: @twoTestmean2
      meanMax: @twoTestmeanMax
      sigma1: @twoTestsigma1
      sigma2: @twoTestsigma2
      sigmaMax: @twoTestsigmaMax
      power: @twoTestpower
      t: @twoTestt
      pvl: @twoTestpvalue
      comp: @comp_agents
      mode: @twoTestmode

    @twoTestUpdate()

  saveData: (data) ->
    @populations = data.populations
    if (data.chosenCol.length is 2)
      @comp_agents = data.chosenCol
    else
      @comp_agents = data.chosenVar
    @twoTestReceiveData()

  setAlpha: (alphaIn) ->
    @twoTestalpha = alphaIn
    @twoTestUpdate()
    @twoTestCheckRange()
    return

  getName: () ->
    return @name

  getParams: () ->
    @parameters =
      n1: @twoTestn1
      n2: @twoTestn2
      nMax: @twoTestmaxn
      mean1: @twoTestmean1
      mean2: @twoTestmean2
      meanMax: @twoTestmeanMax
      sigma1: @twoTestsigma1
      sigma2: @twoTestsigma2
      sigmaMax: @twoTestsigmaMax
      power: @twoTestpower
      t: @twoTestt
      pvl: @twoTestpvalue
      comp: @comp_agents
      mode: @twoTestmode

  setParams: (newParams) ->
    @twoTestn1 = newParams.n1
    @twoTestn2 = newParams.n2
    @twoTestmaxn = newParams.nMax
    @twoTestmean1 = newParams.mean1
    @twoTestmean2 = newParams.mean2
    @twoTestmeanMax = newParams.meanMax
    @twoTestsigma1 = newParams.sigma1
    @twoTestsigma2 = newParams.sigma2
    @twoTestsigmaMax = newParams.sigmaMax
    @twoTestpower = newParams.power
    @twoTestmode = newParams.mode
    @twoTestUpdate()
    return

  savePower: (newParams) ->
    @twoTestpower = newParams.power
    @twoTestmode = newParams.mode
    @twoTestPowerTon()
    return

  reset: () ->
    @twoTestn1 = 10
    @twoTestn2 = 10
    @twoTestmaxn1 = 20
    @twoTestmaxn2 = 20
    @twoTestmaxn = 20
    @twoTestmean1 = 10
    @twoTestmean2 = 10
    @twoTestmeanMax1 = 20
    @twoTestmeanMax2 = 20
    @twoTestmeanMax = 20
    @twoTestsigma1 = 20
    @twoTestsigma2 = 20
    @twoTestsigmaMax1 = 40
    @twoTestsigmaMax2 = 40
    @twoTestsigmaMax = 40
    @twoTestalpha = 0.010
    @twoTestpower = 0
    @twoTestpowerMax = 1
    @twoTestt = 0
    @twoTestpvalue = 0
    @comp_agents = []
    @twoTestmode = "Two Tailed"
    @twoTestUpdate()
    return

  twoTestReceiveData: () ->
    item1 = Object.keys(@populations)[0]
    item2 = Object.keys(@populations)[1]
    @twoTestn1 = @populations[item1].length
    @twoTestn2 = @populations[item2].length
    @twoTestmean1 = @getMean(@getSum(@populations[item1]),@populations[item1].length)
    @twoTestmean2 = @getMean(@getSum(@populations[item2]),@populations[item2].length)
    twoTestvariance1 = @getVariance(@populations[item1], @twoTestmean1)
    twoTestvariance2 = @getVariance(@populations[item2], @twoTestmean2)
    @twoTestsigma1 = Math.sqrt(twoTestvariance1)
    @twoTestsigma2 = Math.sqrt(twoTestvariance2)
    @twoTestCheckRange()
    @twoTestUpdate()
    return

  twoTestCheckRange:() ->
    @twoTestmaxn1 = Math.max(@twoTestn1, @twoTestmaxn1)
    @twoTestmaxn2 = Math.max(@twoTestn2, @twoTestmaxn2)
    @twoTestmaxn = Math.max(@twoTestmaxn1, @twoTestmaxn2)
    @twoTestmeanMax1 = Math.max(@twoTestmean1, @twoTestmeanMax1)
    @twoTestmeanMax2 = Math.max(@twoTestmean2, @twoTestmeanMax2)
    @twoTestmeanMax = Math.max(@twoTestmeanMax1, @twoTestmeanMax2)
    @twoTestsigmaMax1 = Math.max(@twoTestsigma1, @twoTestsigmaMax1)
    @twoTestsigmaMax2 = Math.max(@twoTestsigma2, @twoTestsigmaMax2)
    @twoTestsigmaMax = Math.max(@twoTestsigmaMax1, @twoTestsigmaMax2)

  twoTestUpdate: () ->
    twoTestvar1 = Math.pow(@twoTestsigma1,2)
    twoTestvar2 = Math.pow(@twoTestsigma2,2)
    kappa = @twoTestn1 / @twoTestn2
    # calculate power using different modes
    if @twoTestmode is "Two Tailed"
      z = (@twoTestmean1 - @twoTestmean2) / (Math.sqrt(twoTestvar1 + twoTestvar2) * Math.sqrt((1+(1 / kappa)) / @twoTestn2))
      @twoTestpower = @distribution.pnorm(z-@distribution.qnorm(1-@twoTestalpha/2))+@distribution.pnorm(-z-@distribution.qnorm(1-@twoTestalpha/2))
      @parameters.power = @twoTestpower
    else
      z = (@twoTestmean1 - @twoTestmean2) / Math.sqrt(twoTestvar1 + twoTestvar2 / kappa) * Math.sqrt(@twoTestn1)
      @twoTestpower = @distribution.pnorm(z-@distribution.qnorm(1-@twoTestalpha))
      @parameters.power = @twoTestpower
    @twoTestTTest()
    @twoTestCheckRange()
    return

  twoTestPowerTon: () ->
    kappa = @twoTestn1 / @twoTestn2
    stdv = Math.sqrt(Math.pow(@twoTestsigma1,2) + Math.pow(@twoTestsigma2,2))
    twoTestvar1 = Math.pow(@twoTestsigma1,2)
    twoTestvar2 = Math.pow(@twoTestsigma2,2)
    # calculate n1 or n2 from power based on different mdoes
    if @twoTestmode is "Two Tailed"
      @twoTestn2 = (1 + 1 / kappa)*Math.pow(stdv*(@distribution.qnorm(1-@twoTestalpha / 2)+@distribution.qnorm(@twoTestpower))/(@twoTestmean1-@twoTestmean2),2)
      @twoTestn2 = Math.ceil(@twoTestn2)
      @twoTestmaxn2 = Math.max(@twoTestmaxn2, @twoTestn2)
      # @parameters.n2 = @twoTestn2
    else
      @twoTestn1=(twoTestvar1 + twoTestvar2 / kappa) * Math.pow((@distribution.qnorm(1-@twoTestalpha)+@distribution.qnorm(@twoTestpower))/(@twoTestmean1-@twoTestmean2),2)
      @twoTestn1 = Math.ceil(@twoTestn1)
      @twoTestmaxn2 = Math.max(@twoTestmaxn1, @twoTestn1)
      # @parameters.n1 = @twoTestn1
    @twoTestCheckRange()
    #@twoTestGraph()
    return

  twoTestTTest: () ->
    v1 = Math.pow(@twoTestsigma1,2) / @twoTestn1
    v2 = Math.pow(@twoTestsigma2,2) / @twoTestn2
    df =  Math.pow((v1 + v2),2) / (Math.pow(v1,2) / (@twoTestn1 - 1.0) + Math.pow(v2,2) / (@twoTestn2 - 1.0))
    @twoTestt = @tdistr(df, 1-@twoTestalpha)
    @twoTestpvalue = @tprob(df, @twoTestt)

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
    mean1 = @twoTestmean1
    stdDev1 = @twoTestsigma1
    mean2 = @twoTestmean2
    stdDev2 = @twoTestsigma2
    alpha = @twoTestalpha

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

  tprob: ($n, $x) ->
    if $n <= 0
      throw 'Invalid n: $n\n'
      ### degree of freedom ###
    @precisionString @subtprob($n - 0, $x - 0)
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
  subtprob: ($n, $x) ->
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
  tdistr: ($n, $p) ->
    if $n <= 0
      throw 'Invalid n: $n\n'
    if $p <= 0 or $p >= 1
      throw 'Invalid p: $p\n'
    @precisionString @subt($n - 0, $p - 0)
  subt: ($n, $p) ->
    if $p >= 1 or $p <= 0
      throw 'Invalid p: $p\n'
    if $p == 0.5
      return 0
    else if $p < 0.5
      return -@subt($n, 1 - $p)
    $u = @subu($p)
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
        $p1 = @subtprob($n, $x)
        $n1 = $n + 1
        $delta = ($p1 - $p) / Math.exp(($n1 * Math.log($n1 / ($n + $x * $x)) + Math.log($n / $n1 / 2 / Math.PI) - 1 + (1 / $n1 - (1 / $n)) / 6) / 2)
        $x += $delta
        $round = @roundToPrecision($delta, Math.abs(@integer(@log10(Math.abs($x)) - 4)))
        unless $x and $round != 0
          break
    $x
  subu: ($p) ->
    $y = -Math.log(4 * $p * (1 - $p))
    $x = Math.sqrt($y * (1.570796288 + $y * (.03706987906 + $y * (-.8364353589e-3 + $y * (-.2250947176e-3 + $y * (.6841218299e-5 + $y * (0.5824238515e-5 + $y * (-.104527497e-5 + $y * (.8360937017e-7 + $y * (-.3231081277e-8 + $y * (.3657763036e-10 + $y * .6936233982e-12)))))))))))
    if $p > .5
      $x = -$x
    $x
