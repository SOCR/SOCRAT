'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_powercalc_twoProp
  @type: service
  @desc: Performs two sample proportion test
###


module.exports = class PowerCalcTwoProp extends BaseService
  @inject 'app_analysis_powerCalc_msgService',
    '$timeout'

   initialize: ->
    @distanceFromMean = 5
    @SIGNIFICANT = 5
    @populations = null
    @distribution = require 'distributome'
    @msgService = @app_analysis_powerCalc_msgService
    @name = 'Test of Two Proportions'

    #variables needed globally
    @twoPropP1 = 0.5
    @twoPropP2 = 0.5
    @twoPropPMax = 1
    @twoPropN1 = 50
    @twoPropN2 = 50
    @twoPropNMax = 100
    @twoPropPower = 0
    @twoPropAlpha = 0.010
    @twoPropT = 0
    @twoPropPvalue = 0
    @compAgents = []
    @mode = 'One Sided'
    @modes = ['One Sided', 'Two Sided']


    #data to observe
    @parameters =
      p1: @twoPropP1
      p2: @twoPropP2
      pMax: @twoPropPMax
      n1: @twoPropN1
      n2: @twoPropN2
      nMax: @twoPropNMax
      power: @twoPropPower
      t: @twoPropT
      pvl: @twoPropPvalue
      comp: @compAgents
      mode: @mode

    @twoPropUpdate()

  saveData: (data) ->
    @twoPropP1 = data.prop1
    @twoPropP2 = data.prop2
    @twoPropN1 = data.size1
    @twoPropN2 = data.size2
    @compAgents = data.target
    @twoPropReceiveData()
    return

  setAlpha: (alphaIn) ->
    @twoPropAlpha = alphaIn
    @twoPropUpdate()
    return

  getName: () ->
    return @name

  getParams: () ->
    @parameters =
      p1: @twoPropP1
      p2: @twoPropP2
      pMax: @twoPropPMax
      n1: @twoPropN1
      n2: @twoPropN2
      nMax: @twoPropNMax
      power: @twoPropPower
      t: @twoPropT
      pvl: @twoPropPvalue
      comp: @compAgents
      mode: @mode

  setParams: (newParams) ->
    @twoPropP1 = newParams.p1
    @twoPropP2 = newParams.p2
    @twoPropN1 = newParams.n1
    @twoPropN2 = newParams.n2
    @mode = newParams.mode
    @twoPropUpdate()
    return

  savePower: (newParams) ->
    @twoPropPower = newParams.power
    @mode = newParams.mode
    @twoPropPowerTon()
    return

  reset: () ->
    @twoPropP1 = 0.5
    @twoPropP2 = 0.49
    @twoPropPMax = 1
    @twoPropN1 = 50
    @twoPropN2 = 50
    @twoPropNMax = 100
    @twoPropPower = 0
    @twoPropAlpha = 0.010
    @twoPropT = 0
    @twoPropPvalue = 0
    @compAgents = []
    @mode = 'One Sided'
    @twoPropUpdate()
    return

  twoPropReceiveData: () ->
    @twoPropUpdate()
    return

  twoPropCheckRange:() ->
    @twoPropNMax = Math.max(@twoPropN1, @twoPropN2, @twoPropNMax)
    return

  twoPropUpdate: () ->
    kappa = @twoPropN1 / @twoPropN2
    z=(@twoPropP1-@twoPropP2) / Math.sqrt(@twoPropP1*(1-@twoPropP1) / @twoPropN2 / kappa+@twoPropP2*(1-@twoPropP2) / @twoPropN2)
    if @mode is "Two Sided"
      @twoPropPower=@distribution.pnorm(z-@distribution.qnorm(1-@twoPropAlpha/2))+@distribution.pnorm(-z-@distribution.qnorm(1-@twoPropAlpha/2))
    else
      @twoPropPower=@distribution.pnorm(Math.abs(z)-@distribution.qnorm(1-@twoPropAlpha))
    @twoPropTTest()
    @twoPropCheckRange()
    return

  twoPropPowerTon: () ->
    # calculate n1 or n2 from power based on different mdoes
    kappa = 1
    if @mode is "Two Sided"
      @twoPropN2=(@twoPropP1*(1-@twoPropP1) / kappa + @twoPropP2*(1-@twoPropP2))*Math.pow(((@distribution.qnorm(1-@twoPropAlpha / 2) + @distribution.qnorm(@twoPropPower))/(@twoPropP1-@twoPropP2)),2)
    else
      @twoPropN2=(@twoPropP1*(1-@twoPropP1) / kappa + @twoPropP2*(1-@twoPropP2))*Math.pow(((@distribution.qnorm(1-@twoPropAlpha) + @distribution.qnorm(@twoPropPower))/(@twoPropP1-@twoPropP2)),2)
    @twoPropTTest()
    @twoPropCheckRange()
    return

  twoPropTTest: () ->
    # @twoPropT = (@twoPropP1-@twoPropP2) / Math.sqrt(@twoPropP1*(1-@twoPropP1) / @twoPropN2 / kappa+@twoPropP2*(1-@twoPropP2) / @twoPropN2)
    # @twoTestPvalue = 1 - @tProb(df, @twoTestT)
    # @twoTestPvalue *= 2 if @twoTestMode is 'Two Tailed'
    # @twoTestPvalue = Math.max(0, @twoTestPvalue)
    # @twoTestPvalue = Math.min(1, @twoTestPvalue)
    return


  getChartData: () ->
    return [@twoPropP1, @twoPropP2]

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
