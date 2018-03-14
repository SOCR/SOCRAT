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

    # dependecies
    @msgService = @app_analysis_powerCalc_msgService
    @name = 'Power of a Simple Poisson Test'
    @powerCalc = require 'powercalc'

    #variables needed for chisquare
    @poissonAlpha = 0.05
    @poissonLambda0 = 1
    @poissonLambba1 = 1
    @poissonLambdaMax = 2
    @poissonSize = 100
    @poissonSizeMax = 200
    @poissonPower = 0.5
    @poissoneAlter = 0
    @poissonLowerBound = 0
    @poissonUpperBound = 1
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
      n: @poissonSize
      alter: @poissoneAlter
      lower: @poissonLowerBound
      upper: @poissonUpperBound


  setParams: (newParams) ->
    @poissonLambda0 = newParams.lambda0
    @poissonLambda1 = newParams.lambda1
    @poissonSize = newParams.n
    @poissoneAlter = newParams.alter
    @poissonLowerBound = newParams.lower
    @poissonUpperBound = newParams.upper
    @update(newParams.target)
    return

  checkRange: () ->
    @poissonLambdaMax = Math.max(@poissonLambdaMax, @poissonLambda0, @poissonLambda1) 
    @poissonSizeMax = Math.max(@poissonSizeMax, @poissonSize)

    @chiSquareChi2Max = Math.max(@chiSquareChi2Max, @chiSquareChi2)
    @chiSquareNMax = Math.max(@chiSquareNMax, @chiSquareN)
    @chiSquareDfMax = Math.max(@chiSquareDf, @chiSquareDfMax)
    return

  update: (tar)->

    # update power
    input = 
      chi2: @chiSquareChi2
      proN: @chiSquareN / @chiSquareEffSize
      n: @chiSquareN
      df: @chiSquareDf
      alpha: @chiSquareAlpha
    params = @powerCalc.SimpleChi2GUI_handle(input)
    @chiSquarePower = params.Power
    @checkRange()
