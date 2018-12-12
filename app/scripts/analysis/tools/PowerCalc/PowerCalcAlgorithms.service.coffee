'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class PowerCalcAlgorithms extends BaseModuleDataService
  @inject 'app_analysis_powerCalc_msgService',
    'app_analysis_powerCalc_twoTest',
    'app_analysis_powerCalc_oneTest',
    'app_analysis_powerCalc_oneProp',
    'app_analysis_powerCalc_twoProp',
    'app_analysis_powerCalc_chi2',
    'app_analysis_powerCalc_poisson',
    'app_analysis_powerCalc_rsquare',
    '$interval'

  initialize: ->
    @msgManager = @app_analysis_powerCalc_msgService
    @twoTest = @app_analysis_powerCalc_twoTest
    @oneTest = @app_analysis_powerCalc_oneTest
    @oneProp = @app_analysis_powerCalc_oneProp
    @twoProp = @app_analysis_powerCalc_twoProp
    @chi2 = @app_analysis_powerCalc_chi2
    @poisson = @app_analysis_powerCalc_poisson
    @rsquare = @app_analysis_powerCalc_rsquare
    @algorithms = [@twoTest, @oneTest, @oneProp, @twoProp, @chi2, @poisson, @rsquare]

  getNames: -> @algorithms.map (alg) -> alg.getName()

  getParamsByName: (algName) ->
    (alg.getParams() for alg in @algorithms when algName is alg.getName()).shift()

  getChartData: (algName) ->
    (alg.getChartData() for alg in @algorithms when algName is alg.getName()).shift()

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
