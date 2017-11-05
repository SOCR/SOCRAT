'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class LaplaceDist extends BaseService
  @inject 'socrat_analysis_modeler_getParams'
  initialize: () ->
    @getParams = @socrat_analysis_modeler_getParams

    @name = 'Laplace'
    @u = 0
    @b = 1

  getName: () ->
    return @name

  pdf: (u, b, x) ->
    return (1 / (2*b))*Math.exp(-(Math.abs(x-u)/b))
    
  
  getLaplaceDistribution: (leftBound, rightBound, u, b) ->
    data = []
    for i in [leftBound...rightBound] by .2
      data.push
        x: i
        y: @pdf(u, b, i)
    console.log(data)
    data
  
  getChartData: (data) ->
    histData = data.dataPoints
    histData = histData.map (row) ->
            x: row[0]
            y: row[1]
            z: row[2]
            r: row[3]
    stats = @getParams.getParams(data)
    data.stats = stats
    data.xMin = d3.min(histData, (d)->parseFloat d.x)
    data.xMax = d3.max(histData, (d)->parseFloat d.x)
    data.curveData = @getLaplaceDistribution(data.xMin, data.xMax, data.stats.mean , @b)
    console.log(data.curveData)
    
    return data


  