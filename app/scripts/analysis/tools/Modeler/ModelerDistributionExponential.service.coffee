'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Implementation of the exponential distribution model

###

module.exports = class ExpDist extends BaseService
  @inject 'app_analysis_modeler_getParams'
  initialize: () ->
#    @getParams = @app_analysis_modeler_getParams

    @name = 'Exponential'
    @gamma = .75

  getName: () ->
    return @name

  pdf: (gamma, x) ->
    return gamma * Math.pow(Math.E, -1*gamma*x)


  getExponentialDistribution: (leftBound, rightBound, gamma) ->
    data = []
    for i in [leftBound...rightBound] by .2
      data.push
        x: i
        y: @pdf(gamma, i)
    data

  getChartData: (params) ->

    curveData = @getExponentialDistribution(params.xMin, params.xMax, @gamma)
    #console.log(curveData)

    return curveData

  getParams: () ->
    params =
      gamma: @gamma

  setParams: (newParams) ->
    @gamma = parseFloat(newParams.stats.gamma.toPrecision(4))



