'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ModelerRouter extends BaseModuleDataService
  @inject 'app_analysis_powerCalc_msgService',
    'socrat_modeler_distribution_normal',
    'socrat_analysis_modeler_kernel_density_plotter',
    '$interval'

  initialize: ->
    @msgManager = @app_analysis_powerCalc_msgService
    @Normal = @socrat_modeler_distribution_normal
    @kernelDensity = @socrat_analysis_modeler_kernel_density_plotter
    @models = [@Normal, @kernelDensity]

  ############

  getNames: -> @models.map (model) -> model.getName()

  getParamsByName: (modelName) ->
    (model.getParams() for model in @models when modelName is model.getName()).shift()

  getChartData: (modelName, dataIn) ->
    (model.getChartData(dataIn) for model in @models when modelName is model.getName()).shift()

  setParamsByName: (modelName, dataIn) ->
    (model.setParams(dataIn) for model in @models when modelName is model.getName()).shift()

  passDataByName: (modelName, dataIn) ->
    (model.saveData(dataIn) for model in @models when modelName is model.getName()).shift()

  setPowerByName: (modelName, dataIn) ->
    (model.savePower(dataIn) for model in @models when modelName is model.getName()).shift()

  passAlphaByName: (modelName, alphaIn) ->
    (model.setAlpha(alphaIn) for model in @models when modelName is model.getName()).shift()

  resetByName: (modelName) ->
    (model.reset() for model in @models when modelName is model.getName()).shift()
