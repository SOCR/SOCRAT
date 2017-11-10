'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class MaxwellBoltzman extends BaseService
  @inject 'socrat_analysis_modeler_getParams'
  initialize: () ->
    @getParams = @socrat_analysis_modeler_getParams

    @name = 'Maxwell-Boltzman'
    @a = 1
    

  getName: () ->
    return @name

  pdf: (x, a) ->
    exp = -1* Math.pow(x, 2) / (2* Math.pow(a,2))
    return Math.sqrt(2 / Math.PI) * ((Math.pow(x,2) * Math.pow(Math.E, exp)) / Math.pow(a,3))
    
  
  getMaxwellBoltzmanDistribution: (leftBound, rightBound, a) ->
    data = []
    for i in [leftBound...rightBound] by .2
      data.push
        x: i
        y: @pdf(i, a)
    console.log(data)
    data
  
  getChartData: (params) ->
    data.curveData = @getMaxwellBoltzmanDistribution(params.xMin, params.xMax, @a)
    console.log(data.curveData)
    
    return data


  