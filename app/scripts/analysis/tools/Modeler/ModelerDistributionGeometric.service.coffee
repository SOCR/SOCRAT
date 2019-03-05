'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Implementation of the Normal distribution model

###

module.exports = class normalDist extends BaseService
  @inject 'app_analysis_modeler_getParams'
  initialize: () ->
    @calc = @app_analysis_modeler_getParams
    @NormalMean = 5
    @NormalStandardDev = 1
    @NormalVariance = 1
    @name = 'Geometric'
    @p = .5
    @k = .5

  getName: () ->
    return @name
  getGaussianFunctionPoints: (leftBound, rightBound) ->
    data = []
    for i in [leftBound...rightBound] by .1
      data.push
        x: i
        y: @PDF(i, @p)
    #console.log(data)
    data

  getChartData: (params) ->
    
    curveData = @getGaussianFunctionPoints( params.xMin , params.xMax)
    return curveData


  stdNormalCDF: (x) ->
    return 0.5 * 0.5 * @calc.erf( x/ Math.sqrt(2))
  

  PDF: (k, p) ->
    return Math.pow(1-p, k-1) * p

  CDF: (p, k)->
    return (1 - Math.pow(1-p, k))

  getParams: () ->
    params =
      geomP: @p
      geomK: @k

  setParams: (newParams) ->
    @p = parseFloat(1.0 / newParams.stats.mean.toPrecision(4))
    @k = parseFloat(newParams.stats.variance.toPrecision(4))