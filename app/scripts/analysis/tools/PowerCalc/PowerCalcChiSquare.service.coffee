'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_powercalc_chiSquare
  @type: service
  @desc: Performs chiSquare test analysis
###


module.exports = class PowerCalcTwoTGUI extends BaseService
  @inject 'app_analysis_powerCalc_msgService',
    '$timeout'

  initialize: ->

    # dependecies
    @msgService = @app_analysis_powerCalc_msgService
    @name = 'Two-sample t test (general case)'
    #variables needed for twoTest
    

    #data to observe
    @parameters =

    @twoTestUpdate()

  saveData: (data) ->

  setAlpha: (alphaIn) ->

  getName: () ->
    return @name

  getParams: () ->
    @parameters =

  setParams: (newParams) ->
    return

  savePower: (newParams) ->
    return