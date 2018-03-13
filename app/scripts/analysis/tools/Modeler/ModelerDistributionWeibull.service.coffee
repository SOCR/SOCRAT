'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Implementation of the Weibull distribution model

###

module.exports = class WeiDist extends BaseService
  @inject 'app_analysis_modeler_getParams'
  initialize: () ->
#    @getParams = @app_analysis_modeler_getParams

    @name = 'Weibull'
    @gamma = .75
    @k = 1

  getName: () ->
    return @name

  pdf: (gamma, k, x) ->
    return k/gamma * Math.pow(x/gamma, k-1)* Math.pow(Math.E, -1*Math.pow(x/gamma,k))


  getWeibullDistribution: (leftBound, rightBound, gamma, k) ->
    data = []
    for i in [leftBound...rightBound] by .2
      data.push
        x: i
        y: @pdf(gamma, k, i)
    data

  getChartData: (params) ->

    curveData = @getWeibullDistribution(params.xMin, params.xMax, @gamma, @k)
    #console.log(curveData)

    return curveData

  getParams: () ->
    params =
      gamma: @gamma

  setParams: (newParams) ->
    @gamma = parseFloat(newParams.stats.gamma.toPrecision(4))



