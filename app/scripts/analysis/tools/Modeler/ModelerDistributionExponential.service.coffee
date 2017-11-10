'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class ExpDist extends BaseService
  @inject 'socrat_analysis_modeler_getParams'
  initialize: () ->
    @getParams = @socrat_analysis_modeler_getParams

    @name = 'Exponential'
    @gamma = .75

  getName: () ->
    return @name

  pdf: (gamma, x) ->
    return gamma * Math.pow(Math.E, -1*gamma*x)
    
  
  getDistribution: (leftBound, rightBound, gamma) ->
    data = []
    for i in [leftBound...rightBound] by .2
      data.push
        x: i
        y: @pdf(gamma, i)
    data
  
  getChartData: (params) ->
    if params.stats.gamma == undefined
      params.stats.gamma = .5

    curveData = @getDistribution(params.xMin, params.xMax, params.stats.gamma)
    console.log(curveData)
    
    return curveData


  