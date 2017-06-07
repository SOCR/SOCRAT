'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class PowerCalc_OneTGUI extends BaseService
    
  initialize: ->
    @distanceFromMean = 5


  extract: (data, variable) ->
    tmp = []
    for d in data
      tmp.push +d[variable]
    tmp

  getRightBound: (middle,step) ->
    return middle + step * @distanceFromMean

  getLeftBound: (middle,step) ->
    return middle - step * @distanceFromMean

  sort: (values) ->
    values.sort (a, b) -> a-b

  getVariance: (values, mean) ->
    temp = 0
    numberOfValues = values.length
    while( numberOfValues--)
      temp += Math.pow( (parseInt(values[numberOfValues]) - mean), 2 )

    return temp / values.length

  getSum: (values) ->
    values.reduce (previousValue, currentValue) -> parseFloat(previousValue) + parseFloat(currentValue)

  getGaussianFunctionPoints: (std, mean, variance, leftBound, rightBound) ->
    data = []
    for i in [leftBound...rightBound] by 1
      data.push
        x: i
        y:(1 / (std * Math.sqrt(Math.PI * 2))) * Math.exp(-(Math.pow(i - mean, 2) / (2 * variance)))
    data

  getMean: (valueSum, numberOfOccurrences) ->
    valueSum / numberOfOccurrences

  getZ: (x, mean, standardDerivation) ->
    (x - mean) / standardDerivation

  getWeightedValues: (values) ->
    weightedValues= {}
    data= []
    lengthValues = values.length
    for i in [0...lengthValues] by 1
      label = values[i].toString()
      if(weightedValues[label])
        weightedValues[label].weight++
      else
        weightedValues[label]={weight :1,value :label}
        data.push(weightedValues[label])
    return data

  getRandomNumber: (min,max) ->
    Math.round((max-min) * Math.random() + min)

  getRandomValueArray: (data) ->
    values = []
    length = data.length
    for i in [1...length]
      values.push data[Math.floor(Math.random() * data.length)]
    return values

  drawNormalCurve: (mean_in1, variance_in1, sigma_in1, alpha_in) ->
    margin = {top: 20, right: 20, bottom: 20, left:20}
    width = 500 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom

    container = d3.select("#One_TGUI_graph")
    container.select("svg").remove()

    svg = container.append('svg')
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)

    _graph = svg.append('g')
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")


    mean1 = mean_in1
    variance1 = variance_in1
    standardDerivation1 =  sigma_in1

    rightBound = @getRightBound(mean1, standardDerivation1)
    leftBound = @getLeftBound(mean1, standardDerivation1)
    bottomBound = 0
    topBound = 1 / (standardDerivation1 * Math.sqrt(Math.PI * 2))
    gaussianCurveData1 = @getGaussianFunctionPoints(standardDerivation1,mean1,variance1,leftBound,rightBound)

    radiusCoef = 5
    
    padding = 50
    xScale = d3.scale.linear().range([0, width]).domain([leftBound, rightBound])
    #console.log "xScale: " + xScale
    yScale = d3.scale.linear().range([height-padding, 0]).domain([bottomBound, topBound])

    xAxis = d3.svg.axis().ticks(20)
    .scale(xScale)

    yAxis = d3.svg.axis()
    .scale(yScale)
    .ticks(10)
    .tickPadding(0)
    .orient("right")

    lineGen = d3.svg.line()
    .x (d) -> xScale(d.x)
    .y (d) -> yScale(d.y)
    .interpolate("basis")


    # data1
    path1 = _graph.append('svg:path')
    .attr('d', lineGen(gaussianCurveData1))
    .data([gaussianCurveData1])
    .attr('stroke', 'black')
    .attr('stroke-width', 5)
    .attr('fill', "blue")
    .style("opacity", 0.5)

    # x-axis
    _graph.append("svg:g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + (height - padding) + ")")
    .call(xAxis)

    # y-axis
    _graph.append("svg:g")
    .attr("class", "y axis")
    .attr("transform", "translate(" + (xScale(leftBound))+ ",0)")
    .call(yAxis)
    
    # make x y axis thin
    _graph.selectAll('.x.axis path')
    .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
    _graph.selectAll('.y.axis path')
    .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
    
    # display lengend1
    svg.append("text")
    .attr("id", "OneTGUI_display_legend1")
    .attr("x", xScale(rightBound*0.9))
    .attr("y", yScale(topBound*0.9))
    .style("text-anchor", "middle")
    .attr('fill', "blue");

    
    # rotate text on x axis
    _graph.selectAll('.x.axis text')
    .attr('transform', (d) ->
       'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
    .style('font-size', '16px')

    return

