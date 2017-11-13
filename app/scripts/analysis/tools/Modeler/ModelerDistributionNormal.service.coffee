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
    @NormalMean = newParams.stats.mean
    @NormalStandardDev =newParams.stats.standardDev
    @NormalVariance = newParams.stats.variance