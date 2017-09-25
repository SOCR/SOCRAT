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
    @name = 'kernelDensity'
    @getParams = @socrat_analysis_modeler_getParams


  getName: () ->
    return @name


  getChartData: (data) ->
    data = data.dataPoints
    

  kernelDensityEstimator = (kernel, x) ->
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
    console.log(kde(data))
    kde_curve_data = kde(data)
    #console.log("appending graph")
    '''
    _graph.append('svg:path')
      .datum(kde(data))
      .attr('class', 'line')
      .attr('d', lineGen)
      .attr('stroke', 'black')
      .attr('stroke-width', 1.5)
      .attr('fill', "none")
    #mike bostock way
   _graph.append('svg:path')
      .datum(kde(data))
      .attr("class", "line")
      .attr("d", lineGen);

    '''

    #gaussian way
    _graph.append('svg:path')
      .attr('d', lineGen(kde_curve_data))
      .data([kde_curve_data])
      .attr('stroke', 'black')
      .attr('stroke-width', 1.5)
      .attr('fill', "none")
