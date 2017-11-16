'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class NormalDist extends BaseService
  @inject 'socrat_analysis_modeler_getParams'
  initialize: () ->
    @calc = @socrat_analysis_modeler_getParams
    @NormalMean = 5
    @NormalStandardDev = 1
    @NormalVariance = 1
    @name = 'Normal'



  getName: () ->
    return @name


  getChartData: (params) ->
    
    curveData = @calc.getGaussianFunctionPoints(@NormalStandardDev, @NormalMean, @NormalVariance, params.xMin , params.xMax)
    return curveData


  getParams: () ->
    params =
      mean: @NormalMean
      standardDev: @NormalStandardDev
      variance: @NormalVariance



  setParams: (newParams) ->
    @NormalMean = parseFloat(newParams.stats.mean.toPrecision(4))
    @NormalStandardDev =parseFloat(newParams.stats.standardDev.toPrecision(4))
    @NormalVariance = parseFloat(newParams.stats.variance.toPrecision(4))