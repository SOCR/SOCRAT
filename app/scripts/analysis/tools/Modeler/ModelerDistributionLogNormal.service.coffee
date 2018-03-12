'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Implementation of the log normal distribution model

###

module.exports = class LogNorm extends BaseService
  @inject 'app_analysis_modeler_getParams'
  initialize: () ->
#    @getParams = @app_analysis_modeler_getParams

    @name = 'LogNormal'
    @LogNormalMean = 2
    @LogNormalStdev = 0.5

  getName: () ->
    return @name

  pdf: (stdev, mean, x) ->
    return 1/(x*stdev*Math.sqrt(2*Math.PI))* Math.pow(Math.E,(-1*(Math.pow(Math.log(x)-mean,2))/2*stdev*stdev))


  getLogNormalDistribution: (leftBound, rightBound, stdev, mean) ->
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
    curveData = @getLogNormalDistribution(params.xMin, params.xMax, @LogNormalStdev, @LogNormalMean)
    #console.log(curveData)

    return curveData

  getParams: () ->
    params =
      mean: @LogNormalMean
      standardDev: @LogNormalStdev



  setParams: (newParams) ->
    @LogNormalMean = parseFloat(newParams.stats.mean.toPrecision(4))
    @LogNormalStdev = parseFloat(newParams.stats.standardDev.toPrecision(4))


