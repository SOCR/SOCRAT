'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class PowerCalc_TwoTGUI extends BaseService

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
      temp += Math.pow( (values[numberOfValues ] - mean), 2 )

    return temp / values.length

  getSum: (values) ->
    values.reduce (previousValue, currentValue) -> previousValue + currentValue

  getGaussianFunctionPoints: (std, mean, variance, leftBound, rightBound) ->
    data = []
    for i in [leftBound...rightBound] by 1
      data.push
        x: i
        y:(1 / (std * Math.sqrt(Math.PI * 2))) * Math.exp(-(Math.pow(i - mean, 2) / (2 * variance)))
    console.log(data)
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

  drawNormalCurve: (mean_in, variance_in, sigma_in, alpha_in) ->
    margin = {top: 10, right: 40, bottom: 50, left:80}
    width = 750 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom

    d3.select("#Two_TGUI_graph").select("svg").remove()

    _graph = d3.select("#Two_TGUI_graph").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    alpha = alpha_in
    mean = mean_in
    #console.log "mean: " + mean
    variance = variance_in
    standardDerivation =  sigma_in
    #console.log "sd: " + standardDerivation
    rightBound = @getRightBound(mean, standardDerivation)
    #console.log "rightBound: " + rightBound
    leftBound = @getLeftBound(mean, standardDerivation)
    #console.log "left: " + leftBound
    bottomBound = 0
    topBound = 1 / (standardDerivation * Math.sqrt(Math.PI * 2))
    gaussianCurveData = @getGaussianFunctionPoints(standardDerivation,mean,variance,leftBound,rightBound)
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

    _graph.append('svg:path')
    .attr('d', lineGen(gaussianCurveData))
    .data([gaussianCurveData])
    .attr('stroke', 'black')
    .attr('stroke-width', 2)
    .attr('fill', "aquamarine")


    _graph.append("svg:g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + (height - padding) + ")")
    .call(xAxis)

    _graph.append("svg:g")
    .attr("class", "y axis")
    .attr("transform", "translate(" + (xScale(mean)) + ",0)")
    .call(yAxis)
    
    # make x y axis thin
    _graph.selectAll('.x.axis path')
    .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
    _graph.selectAll('.y.axis path')
    .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
        

    _graph.append("svg:g")
    .append("text")      #text label for the x axis
    .attr("x", width/2 + width/4  )
    .attr("y", 20)
    .style("text-anchor", "middle")
    .style("fill", "white")


    _graph.append("svg:line")
    .attr("y1", bottomBound)
    .attr("y2", topBound)
    .attr("x1", alpha_in)
    .attr("x2", alpha_in)
    .attr('stroke', 'red')
    .attr('stroke-width', 2)
    
    # rotate text on x axis
    _graph.selectAll('.x.axis text')
    .attr('transform', (d) ->
       'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
    .style('font-size', '16px')

