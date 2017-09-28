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


  getChartData: (data) ->
    stats = @getParams.getParams(data)
    data.stats = stats
    data.curveData = @getParams.getGaussianFunctionPoints(stats.standardDev, stats.mean, stats.variance, stats.leftBound, stats.rightBound)
    return data


