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
  
  getChartData: (params) ->
    curveData = @getLaplaceDistribution(params.xMin, params.xMax, params.stats.mean , @b)    
    return curveData


  