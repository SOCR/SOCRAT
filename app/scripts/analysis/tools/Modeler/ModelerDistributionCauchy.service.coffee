'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class CauchyDist extends BaseService
  @inject 'socrat_analysis_modeler_getParams'
  initialize: () ->
    @calc = @socrat_analysis_modeler_getParams

    @name = 'Cauchy'
    @CauchyGamma = .75
    @locationParam = 1

  getName: () ->
    return @name

  cauchy: (locationParam, gamma, x) ->
    return 1 / (Math.PI * gamma *(1 +( Math.pow((x - locationParam) / gamma ,2))))
    
  
  getCauchyDistribution: (leftBound, rightBound, locationParam, gamma) ->
    data = []
    for i in [leftBound...rightBound] by .2
      data.push
        x: i
        y: @cauchy(locationParam, gamma, i)
    console.log(data)
    data
  
  getChartData: (params) ->
    curveData = @getCauchyDistribution(params.xMin, params.xMax, @locationParam, @CauchyGamma)
    console.log(curveData)
    
    return curveData


  getParams: () ->
    params = 
      gamma: @CauchyGamma
      location: @locationParam

  setParams: (newParams) ->
    @CauchyGamma = newParams.stats.gamma
    @locationParam = newParams.stats.location