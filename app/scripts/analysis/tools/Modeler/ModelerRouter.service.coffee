'use strict'

###
  @name:
  @type: service
  @desc: Service to allow the main controller to access the different distribution

###
BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ModelerRouter extends BaseModuleDataService
  @inject 'app_analysis_modeler_msgService',
    'app_analysis_modeler_distrNormal',
    'app_analysis_modeler_distrLaplace',
    'app_analysis_modeler_distrCauchy',
    'app_analysis_modeler_distrMaxwellBoltzman',
    'app_analysis_modeler_distrBinomial',
    'app_analysis_modeler_kernelDensityPlotter',
    'app_analysis_modeler_distrChiSquared',
    'app_analysis_modeler_distrLogNormal',
    'app_analysis_modeler_distrExponential',

    '$interval'

  initialize: ->
    #import each distribution file
    @msgManager = @app_analysis_modeler_msgService
    @Normal = @app_analysis_modeler_distrNormal
    @Kernel = @app_analysis_modeler_kernelDensityPlotter
    @Laplace = @app_analysis_modeler_distrLaplace
    @Cauchy = @app_analysis_modeler_distrCauchy
    @MaxwellBoltzman = @app_analysis_modeler_distrMaxwellBoltzman
    @Binomial = @app_analysis_modeler_distrBinomial
    @ChiSquared = @app_analysis_modeler_distrChiSquared
    @LogNormal= @app_analysis_modeler_distrLogNormal
    @Exponential =@app_analysis_modeler_distrExponential

    #@models = [@Normal, @Kernel, @Laplace, @Cauchy, @MaxwellBoltzman, @Binomial, @Exponential ]
    #add distribution to the available models list
    @models = [@Normal, @Laplace, @ChiSquared, @MaxwellBoltzman, @LogNormal, @Cauchy, @Exponential, @Kernel]

  getNames: -> @models.map (model) -> model.getName()

  getParamsByName: (modelName) ->
    (model.getParams() for model in @models when modelName is model.getName()).shift()

  getChartData: (modelName, params) ->
    (model.getChartData(params) for model in @models when modelName is model.getName()).shift()

  setParamsByName: (modelName, params) ->
    (model.setParams(params) for model in @models when modelName is model.getName()).shift()



  getQuantile: (modelName, params, p) ->
    a = Math.min(0, params.xMin)
    b = params.xMax
    for model in @models when modelName is model.getName()
      if p == 0
        a
      else if p == 1
        b
      else if 0 < p & p < 1
        x1 = a
        x2 = b
        x = (x1 + x2) / 2
        q = model.CDF(x)
        e = Math.abs(q-p)
        k = 1
        while e > 0.00001 and k < 100
          k++
          if q < p then x1 = x else x2 = x
          x = (x1 + x2) / 2
          q = model.CDF(x)
          e = Math.abs(q-p)


      return x
