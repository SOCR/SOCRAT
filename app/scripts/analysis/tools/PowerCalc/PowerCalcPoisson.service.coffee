'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_powercalc_poisson
  @type: service
  @desc: Performs simple poisson test analysis
###


module.exports = class PowerCalcPoisson extends BaseService
  @inject 'app_analysis_powerCalc_msgService',
    '$timeout'

  initialize: ->

    # dependencies
    @msgService = @app_analysis_powerCalc_msgService
    @name = 'Power of a Simple Poisson Test'
    @powerCalc = require 'powercalc'

    #variables needed for poisson
    @poissonAlpha = 0.05
    @poissonLambda0 = 1
    @poissonLambda1 = 1
    @poissonLambdaMax = 2
    @poissonSize = 100
    @poissonSizeMax = 200
    @poissonPower = 0.5
    @poissonAlter = 0
    @poissonLowerBound = 0
    @poissonUpperBound = 1
    @poissonAlterInt = 0
    @update()

  setAlpha: (alphaIn) ->
    @poissonAlpha = alphaIn
    @update()
    return

  saveData: (data) ->
    # TODO
    return

  getName: () ->
    return @name

  getParams: () ->
    @parameters =
      power: @poissonPower
      lambda0: @poissonLambda0
      lambda1: @poissonLambda1
      lambdaMax: @poissonLambdaMax
      n: @poissonSize
      nMax: @poissonSizeMax
      alt: @poissonAlter
      lower: @poissonLowerBound
      upper: @poissonUpperBound
    return @parameters



  setParams: (newParams) ->
    @poissonLambda0 = newParams.lambda0
    @poissonLambda1 = newParams.lambda1
    @poissonSize = newParams.n
    @poissonAlt = newParams.alt
    if @poissonAlter is "lambda < lambda0" then @poissonAlterInt = 0
    else if @poissonAlter is "lambda != lambda0" then @poissonAlterInt = 1
    else @poissonAlterInt = 2
    @update(newParams.target)

    return

  checkRange: () ->
    @poissonLambdaMax = Math.max(@poissonLambdaMax, @poissonLambda0, @poissonLambda1)
    @poissonSizeMax = Math.max(@poissonSizeMax, @poissonSize)
    return

  update: (tar)->
    input =
      power: @poissonPower
      lambda0: @poissonLambda0
      lambda1: @poissonLambda1
      alpha: @poissonAlpha
      n: @poissonSize
      alt: @poissonAlterInt
    poissonGUI = @powerCalc.SimplePoissonGUI_temp(input, tar)
    @poissonLowerBound = poissonGUI.lower
    @poissonUpperBound = poissonGUI.upper
    @poissonPower = poissonGUI.power
    @checkRange()
