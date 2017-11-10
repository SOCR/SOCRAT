'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class BinomialDist extends BaseService
  @inject 'socrat_analysis_modeler_getParams'
  initialize: () ->
    @getParams = @socrat_analysis_modeler_getParams

    @name = 'Binomial'
    @n = 10;
    @p = .1;

  getName: () ->
    return @name

  pdf: (n, p, x) ->
    
    return @factorial(n)/(@factorial(x) * @factorial(n-x)) * Math.pow(p, x) * Math.pow((1-p), (n-x)) 
    
  factorial: (x) ->
    t = 1
    while( x>1)
      t*= x--
    t

  getBinomialDistribution: (leftBound, rightBound, n, p) ->
    data = []
    for i in [leftBound...rightBound] by .2
      data.push
        x: i
        y: @pdf(n, p, i)
    console.log(data)
    data
  
  getChartData: (params) ->
    if params.stats.n == undefined
      params.stats.n = @n

    if params.stats.p == undefined
      params.stats.p = @p
    

    curveData = @getBinomialDistribution(params.xMin, params.xMax, params.stats.n , params.stats.p)
    console.log(curveData)
    
    return curveData


  