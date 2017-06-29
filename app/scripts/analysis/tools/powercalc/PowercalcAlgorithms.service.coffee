'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class PowercalcAlgorithms extends BaseModuleDataService
  @inject 'app_analysis_powercalc_msgService',
    'app_analysis_powercalc_twoTest',
    '$interval'

  initialize: ->
    @msgManager = @app_analysis_powercalc_msgService
    @twoTest = @app_analysis_powercalc_twoTest
    @algorithms = [@twoTest]

  ############

  getNames: -> @algorithms.map (alg) -> alg.getName()

  getParamsByName: (algName) ->
    (alg.getParams() for alg in @algorithms when algName is alg.getName()).shift()

  getChartData: (algName, params) ->
    (alg.getChartData(params) for alg in @algorithms when algName is alg.getName()).shift()

  setParamsByName: (algName, dataIn) ->
    (alg.setParams(dataIn) for alg in @algorithms when algName is alg.getName()).shift()

  passDataByName: (algName, dataIn) ->
    (alg.saveData(dataIn) for alg in @algorithms when algName is alg.getName()).shift()

  setPowerByName: (algName, dataIn) ->
    (alg.savePower(dataIn) for alg in @algorithms when algName is alg.getName()).shift()

  passAlphaByName: (algName, alphaIn) ->
    (alg.setAlpha(alphaIn) for alg in @algorithms when algName is alg.getName()).shift()

  resetByName: (algName) ->
    (alg.reset() for alg in @algorithms when algName is alg.getName()).shift()
