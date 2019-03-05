'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Implementation of the Normal distribution model

###

module.exports = class NormalDist extends BaseService
  @inject 'app_analysis_modeler_getParams'
  initialize: () ->
    @calc = @app_analysis_modeler_getParams
    @NormalMean = 5
    @NormalStandardDev = 1
    @NormalVariance = 1
    @name = 'Normal'


  getName: () ->
    return @name
  getGaussianFunctionPoints: (leftBound, rightBound) ->
    data = []
    for i in [leftBound...rightBound] by .1
      data.push
        x: i
        y: @PDF(i)
    #console.log(data)
    data

  getChartData: (params) ->
    
    curveData = @getGaussianFunctionPoints( params.xMin , params.xMax)
    return curveData


  stdNormalCDF: (x) ->
    return 0.5 * 0.5 * @calc.erf( x/ Math.sqrt(2))
  

  PDF: (x) ->
    return (1 / (@NormalStandardDev * Math.sqrt(Math.PI * 2))) * Math.exp(-(Math.pow(x - @NormalMean, 2) / (2 * @NormalVariance)))

  CDF: (x)->
    return @stdNormalCDF((x-@NormalMean)/ @NormalStandardDev)

  getParams: () ->
    params =
      mean: @NormalMean
      standardDev: @NormalStandardDev
      variance: @NormalVariance

  setParams: (newParams) ->
    @NormalMean = parseFloat(newParams.stats.mean.toPrecision(4))
    @NormalStandardDev =parseFloat(newParams.stats.standardDev.toPrecision(4))
    @NormalVariance = parseFloat(newParams.stats.variance.toPrecision(4))