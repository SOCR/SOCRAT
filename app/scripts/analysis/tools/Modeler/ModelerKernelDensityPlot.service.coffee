'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Implementation of Kernel Density distribution with multiple kernels

###

module.exports = class KernelDensityPlot extends BaseService
  @inject 'app_analysis_modeler_getParams'

  initialize: () ->
    @name = 'Kernel'
    @calc = @app_analysis_modeler_getParams
    @bandwith = 5

  getName: () ->
    return @name


  getChartData: (params) ->
    #console.log("Getting Kernel Density Data")
    #data = data.dataPoints

    xScale = d3.scale.linear().domain([params.xMin, params.xMax]).range([0, params.xMax])
    kde = @kernelDensityEstimator(@epanechnikovKernel(@bandwith), xScale.ticks(18));
    #console.log("printing kde data ")
    toKDE = data.dataPoints.map (d) ->
      return d[0]
    curveData = kde(toKDE)
    return curveData
    

  kernelDensityEstimator: (kernel, x) ->
    (sample) ->
      x.map (x) ->
        {
          x: x
          y: d3.mean(sample, (v) ->
            kernel x - v
          )
        }
  
  getParams: () ->
    params =
      kernel: @kernel
      bandwith: @bandwith

  setParams: (newParams) ->
    @kernel = parseFloat(newParams.stats.kernel)
    @bandwith = parseFloat(newParams.stats.bandwith).toPrecision(4)

  epanechnikovKernel: (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then .75 * (1 - (u * u)) / scale else 0


  uniform: (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then .5

  triangular: (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then 1 - Math.abs(u)

  
'''
  quartic: (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then (15/16) * (1-(u*u))*(1-(u*u)) else 0

 
  triweight: (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then (35/32) * (1-(u*u))*(1-(u*u)*(1-(u*u)) else 0    


  gaussian: (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then 1 / (Math.sqrt(2*Math.PI) * Math.exp(-.5 * u* U)) 


  cosine : (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then Math.PI / 4 * Math.cos(Math.PI /2 * u)

  
'''