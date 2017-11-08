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
  
  getChartData: (params) ->
    if params.stats.gamma == undefined
      params.stats.gamma = .75

    curveData = @getCauchyDistribution(params.xMin, params.xMax, params.stats.mean , params.stats.gamma)
    console.log(curveData)
    
    return curveData


  