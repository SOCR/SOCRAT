'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class KernelDensityPlot extends BaseService
  @inject 'socrat_analysis_modeler_getParams'

  initialize: () ->
    @name = 'Kernel'
    @getParams = @socrat_analysis_modeler_getParams


  getName: () ->
    return @name


  getChartData: (data) ->
    console.log("Getting Kernel Density Data")
    #data = data.dataPoints
    bandwith = 5

    ####need to remove
    margin = {top: 10, right: 40, bottom: 50, left:80}
    width = 750 - margin.left - margin.right

    ##
    data.stats = @getParams.getParams(data)
    xScale = d3.scale.linear().domain([data.stats.xMin, data.stats.xMax]).range([0, width])
    kde = @kernelDensityEstimator(@epanechnikovKernel(bandwith), xScale.ticks(18));
    console.log("printing kde data ")
    toKDE = data.dataPoints.map (d) ->
      return d[0]
    data.curveData = kde(toKDE)
    console.log(data.stats.xMin)
    console.log(data.stats.xMax)
    console.log( data.curveData)
    return data
    

  kernelDensityEstimator: (kernel, x) ->
    (sample) ->
      x.map (x) ->
        {
          x: x
          y: d3.mean(sample, (v) ->
            kernel x - v
          )
        }

  epanechnikovKernel: (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then .75 * (1 - (u * u)) / scale else 0


  uniform: (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then .5

  triangular: (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then 1 - Math.abs(u)

  quartic: (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then (15/16) * (1-(u*u))*(1-(u*u)) else 0

  ''''
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
  drawKernelDensityEst: (data, width, height, _graph) ->
    console.log("datafrom kde")
    console.log(data)
    #data = data.map (row) ->
    #  x: row[0]
    #  y: row[1]
    #  z: row[2]


    bandwith = 5
    console.log("Within the modeler kernelDensity")
    console.log @getParams.extract(data, "x")
    data =  @getParams.extract(data, "x")
    sample = @getParams.sort(@getParams.getRandomValueArray(@getParams.extract(data,"x")))
    sum = @getParams.getSum(sample)
    min = sample[0]
    max = sample[sample.length - 1]
    mean = @getParams.getMean(sum, sample.length)
    variance = @getParams.getVariance(sample, mean)
    standardDerivation =  Math.sqrt(variance)
    rightBound = @getParams.getRightBound(mean, standardDerivation)
    leftBound = @getParams.getLeftBound(mean,standardDerivation)
    bottomBound = 0
    topBound = 1 / (standardDerivation * Math.sqrt(Math.PI * 2))
    radiusCoef = 5

    padding = 50

    xScale = d3.scale.linear().domain([leftBound, rightBound]).range([0, width])
    yScale = d3.scale.linear().domain([bottomBound, topBound]).range([height-padding, 0])


    #x = d3.scale.linear().range([0, width]).domain([leftBound, rightBound])

    xAxis = d3.svg.axis().ticks(20)
      .scale(xScale)

    yAxis = d3.svg.axis()
      .scale(yScale)
      .ticks(12)
      .tickPadding(0)
      .orient("right")

    lineGen = d3.svg.line()
      .x (d) -> xScale(d.x)
      .y (d) -> yScale(d.y)
      .interpolate("basis")


    kde = @kernelDensityEstimator(@epanechnikovKernel(bandwith), xScale.ticks(100));
    console.log("printing kde(data))")


    #gaussian way
    _graph.append('svg:path')
      .attr('d', lineGen(kde_curve_data))
      .data([kde_curve_data])
      .attr('stroke', 'black')
      .attr('stroke-width', 1.5)
      .attr('fill', "none")
