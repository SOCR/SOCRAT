'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_powercalc_rsquare
  @type: service
  @desc: Performs r-square test analysis
###


module.exports = class PowerCalcPoisson extends BaseService
  @inject 'app_analysis_powerCalc_msgService',
    '$timeout'

  initialize: ->

# dependencies
    @msgService = @app_analysis_powerCalc_msgService
    @name = 'R-square (multiple correlation)'
    @powerCalc = require 'powercalc'

    #variables needed for poisson
    @rSquareAlpha = 0.05
    @rSquareRHO2 = 0.1
    @rSquaren = 50
    @rSquarenMax = 100
    @rSquarePreds = 1
    @rSquarePredsMax = 10
    @rSquarePower = 0.5
    @update()

  setAlpha: (alphaIn) ->
    @rSquareAlpha = alphaIn
    @update()
    return

  saveData: (data) ->
    return

  getName: () ->
    return @name

  getParams: () ->
    @parameters =
      rho2: @rSquareRHO2
      n: @rSquaren
      nMax: @rSquarenMax
      preds: @rSquarePreds
      predsMax: @rSquarePredsMax
      power: @rSquarePower
    return @parameters

  setParams: (newParams) ->
    @rSquareRHO2 = newParams.rho2
    @rSquaren = newParams.n
    @rSquarePreds = newParams.preds
    @update()
    return

  checkRange: () ->
    @rSquarenMax = Math.max(@rSquaren, @rSquarenMax)
    @rSquarePredsMax = Math.max(@rSquarePreds, @rSquarePredsMax)
    return

  update: ()->
    input =
      rho2: @rSquareRHO2
      alpha: @rSquareAlpha
      n: @rSquaren
      preds: @rSquarePreds
      power: @rSquarePower
    params = @powerCalc.RsquareGUI_handle(input)
    @rSquarePower = params.power
    @checkRange()
