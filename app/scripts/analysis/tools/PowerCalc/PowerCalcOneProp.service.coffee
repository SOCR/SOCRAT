'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_powercalc_oneProp
  @type: service
  @desc: Performs one sample proportion test
###


module.exports = class PowerCalcOneProp extends BaseService
  @inject 'app_analysis_powerCalc_msgService',
    '$timeout'

   initialize: ->
    @distanceFromMean = 5
    @SIGNIFICANT = 5
    @populations = null
    @distribution = require 'distributome'
    @jstats = require 'jstat'
    @msgService = @app_analysis_powerCalc_msgService
    @name = 'Test of One Proportion'

    #variables needed globally
    @onePropP = 0.5
    @onePropP0 = 0.5
    @onePropPMax = 1
    @onePropN = 50
    @onePropNMax = 100
    @onePropPower = 0
    @onePropAlpha = 0.010
    @onePropZ = 0
    @onePropPvalue = 0
    @compAgents = ''
    @mode = 'One Sided'
    @modes = ['One Sided', 'Two Sided']


    #data to observe
    @parameters =
      p: @onePropP
      p0: @onePropP0
      pMax: @onePropPMax
      n: @onePropN
      nMax: @onePropNMax
      power: @onePropPower
      z: @onePropZ
      pvl: @onePropPvalue
      comp: @compAgents
      mode: @mode

    @onePropUpdate()

  saveData: (data) ->
    @onePropP = data.prop
    @onePropN = data.size
    @compAgents = data.target
    @onePropReceiveData()
    return

  setAlpha: (alphaIn) ->
    @onePropAlpha = alphaIn
    @onePropUpdate()
    return

  getName: () ->
    return @name

  getParams: () ->
    @parameters =
      p: @onePropP
      p0: @onePropP0
      pMax: @onePropPMax
      n: @onePropN
      nMax: @onePropNMax
      power: @onePropPower
      z: @onePropZ
      pvl: @onePropPvalue
      comp: @compAgents
      mode: @mode

  setParams: (newParams) ->
    @onePropP = newParams.p
    @onePropP0 = newParams.p0
    @onePropN = newParams.n
    @mode = newParams.mode
    @onePropUpdate()
    return

  savePower: (newParams) ->
    @onePropPower = newParams.power
    @mode = newParams.mode
    @onePropPowerTon()
    return

  reset: () ->
    @onePropP = 0.5
    @onePropP0 = 0.5
    @onePropPMax = 1
    @onePropN = 50
    @onePropNMax = 100
    @onePropPower = 0
    @onePropAlpha = 0.010
    @onePropZ = 0
    @onePropPvalue = 0
    @mode = 'Two Sided'
    @compAgents = ''
    @onePropUpdate()
    return

  onePropReceiveData: () ->
    @onePropUpdate()
    return

  onePropCheckRange:() ->
    @onePropNMax = Math.max(@onePropN, @onePropNMax)
    @onePropPMax = Math.max(@onePropP, @onePropP0, @onePropPMax)
    return

  onePropUpdate: () ->
    if @mode is "Two Sided"
      @onePropZ = Math.abs((@onePropP-@onePropP0) / Math.sqrt((@onePropP*(1-@onePropP))/@onePropN))
      @onePropPower=@distribution.pnorm(@onePropZ-@distribution.qnorm(1-@onePropAlpha/2))+@distribution.pnorm(-@onePropZ-@distribution.qnorm(1-@OnePropAlpha/2))
    else
      @onePropZ = Math.abs((@onePropP-@onePropP0) / Math.sqrt(@onePropP0*(1-@onePropP0)/@onePropN))
      @onePropPower=@distribution.pnorm(Math.sqrt(@onePropP0*(1-@onePropP0) / @onePropP / (1-@onePropP))*(Math.abs(@onePropZ)-@distribution.qnorm(1-@onePropAlpha)))
    @onePropPV()
    @onePropCheckRange()
    return

  onePropPowerTon: () ->
    # calculate n1 or n2 from power based on different mdoes
    if @mode is "Two Sided"
      @onePropN = @onePropP*(1-@onePropP)*Math.pow(((@distribution.qnorm(1-@onePropAlpha / 2)+@distribution.qnorm(@onePropPower))/(@onePropP-@onePropP0)),2)
    else
      @onePropN = @onePropP0*(1-@onePropP0)*Math.pow(((@distribution.qnorm(1-@onePropAlpha)+@distribution.qnorm(@onePropAlpha)*Math.sqrt(@onePropP*(1-@onrPropP)/ @onePropP0/ (1-@onePropP0)))/(@onePropP-@onePropP0)),2)
    @onePropPV()
    @onePropCheckRange()
    return

  onePropPV: () ->
    @onePropPvalue = 1 - @getP(@onePropZ)
    @onePropPvalue *= 2 if @mode is 'Two Sided'
    @onePropPvalue = Math.max(0, @onePropPvalue)
    @onePropPvalue = Math.min(1, @onePropPvalue)
    return 0

  getChartData: () ->
    console.log [@onePropP]
    return [@onePropP]

  tProb: ($n, $x) ->
    if $n < 0
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


  getP: (z) ->
    if z < -6.5
      return 0.0
    if z > 6.5
      return 1.0
    factK = 1
    sum = 0
    term = 1
    k = 0
    loopStop = Math.exp(-23)
    while Math.abs(term) > loopStop
      term = .3989422804 * (-1) ** k * z ** k / (2 * k + 1) / 2 ** k * z ** (k + 1) / factK
      sum += term
      k++
      factK *= k
    sum += 0.5
    return sum
