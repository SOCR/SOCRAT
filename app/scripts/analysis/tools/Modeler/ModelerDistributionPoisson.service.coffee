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
    @name = 'Poisson'
    @lambda = 1

  getName: () ->
    return @name
  getGaussianFunctionPoints: (leftBound, rightBound, lambda) ->
    data = []
    for i in [leftBound...rightBound] by .1
      data.push
        x: i
        y: @PDF(i, @lambda)
    #console.log(data)
    data

  getChartData: (params) ->
    
    curveData = @getGaussianFunctionPoints( params.xMin , params.xMax)
    return curveData

  stdNormalCDF: (x) ->
    return 0.5 * 0.5 * @calc.erf( x/ Math.sqrt(2))

  factorial: (x) ->
    t = 1
    while( x>1)
      t*= x--
    t
  
  PDF: (x, lambda) ->
    return Math.pow(2.71828, -lambda) * (Math.pow(lambda, x) / @factorial(x))

  CDF: (p, k)->
    return (1 - Math.pow(1-p, k))

  getParams: () ->
    params =
      geomLambda: @lambda
      #geomK: @k

  setParams: (newParams) ->
    @lambda = parseFloat(1.0 / newParams.stats.mean.toPrecision(4))
    #@k = parseFloat(newParams.stats.variance.toPrecision(4))