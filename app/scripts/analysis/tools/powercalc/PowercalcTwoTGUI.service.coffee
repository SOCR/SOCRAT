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

  drawNormalCurve: (data_in1, mean_in1, variance_in1, sigma_in1, mean_in2, variance_in2, sigma_in2, alpha_in) ->
    margin = {top: 10, right: 40, bottom: 50, left:80}
    width = 750 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom

    d3.select("#Two_TGUI_graph").select("svg").remove()

    _graph = d3.select("#Two_TGUI_graph").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")


    data1 = @sort(data_in1)
    alpha = alpha_in
    index = data1.length - Math.floor (data1.length * alpha)
    criticalVal = data1[index]
    console.log criticalVal

    mean1 = mean_in1
    variance1 = variance_in1
    standardDerivation1 =  sigma_in1

    mean2 = mean_in2
    variance2 = variance_in2
    standardDerivation2 = sigma_in2

    rightBound = Math.max(@getRightBound(mean1, standardDerivation1), @getRightBound(mean2, standardDerivation2))
    leftBound = Math.min(@getLeftBound(mean1, standardDerivation1), @getLeftBound(mean2, standardDerivation2))
    bottomBound = 0
    topBound = Math.max(1 / (standardDerivation1 * Math.sqrt(Math.PI * 2)), 1 / (standardDerivation2 * Math.sqrt(Math.PI * 2)))
    gaussianCurveData1 = @getGaussianFunctionPoints(standardDerivation1,mean1,variance1,leftBound,rightBound)
    gaussianCurveData2 = @getGaussianFunctionPoints(standardDerivation2,mean2,variance2,leftBound,rightBound)

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
    .attr('d', lineGen(gaussianCurveData1))
    .data([gaussianCurveData1])
    .attr('stroke', 'black')
    .attr('stroke-width', 5)
    .attr('fill', "aquamarine")
    .style("opacity", 0.5)


    _graph.append('svg:path')
    .attr('d', lineGen(gaussianCurveData2))
    .data([gaussianCurveData2])
    .attr('stroke', 'red')
    .attr('stroke-width', 5)
    .attr('fill', "yellow")
    .style("opacity", 0.5)



    _graph.append("svg:g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + (height - padding) + ")")
    .call(xAxis)

    _graph.append("svg:g")
    .attr("class", "y axis")
    .attr("transform", "translate(" + (xScale(leftBound))+ ",0)")
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

    _graph.append("svg:g")
    .append("line")
    .attr('x1', criticalVal)
    .attr('x2', criticalVal)
    .attr('y1', 0)
    .attr('y2', topBound)
    .attr('stroke', 'black')
    .attr('stroke-width', 3)

    
    # rotate text on x axis
    _graph.selectAll('.x.axis text')
    .attr('transform', (d) ->
       'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
    .style('font-size', '16px')

