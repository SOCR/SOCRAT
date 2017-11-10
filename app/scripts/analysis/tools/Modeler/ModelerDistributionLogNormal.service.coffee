'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class LogNorm extends BaseService
  @inject 'socrat_analysis_modeler_getParams'
  initialize: () ->
    @getParams = @socrat_analysis_modeler_getParams

    @name = 'LogNormal'
    @mean = .75
    @stdev = 0.5

  getName: () ->
    return @name

  pdf: (stdev, mean, x) ->
    return 1/(x*stdev*Math.sqrt(2*Math.PI))* Math.pow(Math.E,(-1*(Math.pow(Math.log(x)-mean,2))/2*stdev*stdev))


  getDistribution: (leftBound, rightBound, stdev, mean) ->
    data = []
    for i in [leftBound...rightBound] by .2
      data.push
        x: i
        y: @pdf(stdev, mean, i)
    data

  getChartData: (params) ->
    if params.stats.stdev == undefined
      params.stats.stdev = 0.5
    if params.stats.mean == undefined
      params.stats.mean = 0.75
    curveData = @getDistribution(params.xMin, params.xMax, params.stats.standardDev, params.stats.mean)
    console.log(curveData)

    return curveData


