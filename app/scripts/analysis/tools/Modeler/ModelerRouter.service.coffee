'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ModelerRouter extends BaseModuleDataService
  @inject 'app_analysis_powerCalc_msgService',
    'socrat_modeler_distribution_normal',
    'socrat_modeler_distribution_laplace',
    'socrat_modeler_distribution_cauchy',
    'socrat_modeler_distribution_maxwell_boltzman',
    'socrat_modeler_distribution_binomial',
    'socrat_analysis_modeler_kernel_density_plotter',
    'socrat_modeler_distribution_ChiSquared',
    'socrat_modeler_distribution_LogNormal',
    'socrat_modeler_distribution_exponential',
   
    '$interval'

  initialize: ->
    @msgManager = @app_analysis_powerCalc_msgService
    @Normal = @socrat_modeler_distribution_normal
    @Kernel = @socrat_analysis_modeler_kernel_density_plotter
    @Laplace = @socrat_modeler_distribution_laplace
    @Cauchy = @socrat_modeler_distribution_cauchy
    @MaxwellBoltzman = @socrat_modeler_distribution_maxwell_boltzman
    @Binomial = @socrat_modeler_distribution_binomial
    @ChiSquared = @socrat_modeler_distribution_ChiSquared
    @LogNormal= @socrat_modeler_distribution_LogNormal
    @Exponential =@socrat_modeler_distribution_exponential

    #@models = [@Normal, @Kernel, @Laplace, @Cauchy, @MaxwellBoltzman, @Binomial, @Exponential ]
    @models = [@Normal, @Laplace, @ChiSquared, @MaxwellBoltzman, @LogNormal, @Cauchy, @Exponential]

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
    