'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class CauchyDist extends BaseService
  @inject 'socrat_analysis_modeler_getParams'
  initialize: () ->
    @getParams = @socrat_analysis_modeler_getParams

    @name = 'Cauchy'
    @gamma = .75
    @locationParam = null

  getName: () ->
    return @name

  cauchy: (locationParam, gamma, x) ->
    console.log("location")
    console.log(locationParam)
    console.log("gamma")
    console.log(gamma)
    console.log("x")
    console.log(x)
    return 1 / (Math.PI * gamma *(1 +( Math.pow((x - locationParam) / gamma ,2))))
    
  
  getCauchyDistribution: (leftBound, rightBound, locationParam, gamma) ->
    data = []
    for i in [leftBound...rightBound] by .2
      data.push
        x: i
        y: @cauchy(locationParam, gamma, i)
    console.log(data)
    data
  
  getChartData: (data, b) ->
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
    data.curveData = @getCauchyDistribution(data.xMin, data.xMax, data.stats.mean , @gamma)
    console.log(data.curveData)
    
    return data


  