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
    @getParams = @socrat_analysis_modeler_getParams

    @name = 'Normal'


  getName: () ->
    return @name


  getChartData: (params) ->
    
    curveData = @getParams.getGaussianFunctionPoints(params.stats.standardDev, params.stats.mean, params.stats.variance, params.xMin , params.xMax)
    return curveData


