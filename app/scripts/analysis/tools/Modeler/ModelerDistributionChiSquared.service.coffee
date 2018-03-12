'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Implementation of the chi squared distribution model
###

module.exports = class ChiSqr extends BaseService
  @inject 'app_analysis_modeler_getParams'
  initialize: () ->
#    @getParams = @app_analysis_modeler_getParams

    @name = 'ChiSquared'
    @k = 2

  getName: () ->
    return @name

  pdf: (k, x) ->
    return 1/(Math.pow(2, k/2)*@gammaFn(k/2))* Math.pow(x,(k/2-1))*Math.exp(-1*x/2)

  factorial: (x) ->
    t = 1
    while x > 1
      t *= x--
    t

  gammaFn: (x) ->
    #console.log("In te chisquared service!!!!!!!!!!")
    return @factorial(x-1)

  getChiSquaredDistribution: (leftBound, rightBound, k) ->
    data = []
    for i in [leftBound...rightBound] by 0.2
      data.push
        x: i
        y: @pdf(k, i)
    #console.log(data)
    data

  getChartData: (params) ->
#    if params.stats.k == undefined
#      params.stats.k = 2

    curveData = @getChiSquaredDistribution(params.xMin, params.xMax, @k)
    #console.log(curveData)

    return curveData


  getParams: () ->
    params =
      mean: @k



  setParams: (newParams) ->
    @k = newParams.stats.mean
