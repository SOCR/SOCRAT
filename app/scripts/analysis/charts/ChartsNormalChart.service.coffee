'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsNormalChart extends BaseService

distanceFromMean = 5

extract: (data, variable) ->
  tmp = []
  for d in data
    tmp.push +d[variable]
  tmp

getRightBound: (middle,step) ->
  middle + step *distanceFromMean

getLeftBound: (middle,step) ->
  middle - (step*distanceFromMean)

sort: (values) ->
  values.sort (a,b) -> a-b

getVariance: (values,mean) ->
  temp = 0
  numberOfValues = values.length
  while( numberOfValues--)
    temp += Math.pow( (values[numberOfValues ] - mean), 2 )

  return temp / values.length

getSum: (values) ->
  values.reduce (previousValue, currentValue) -> previousValue + currentValue

getGaussianFunctionPoints: (std,mean,variance,leftBound,rightBound) ->
  data = []
  for i in [leftBound...rightBound] by 1
    data.push({x:i,y:(1/(std*Math.sqrt(Math.PI*2)))*Math.exp(-(Math.pow(i-mean,2)/ (2*variance)))})
  console.log(data)
  data;

getMean: (valueSum,numberOfOccurrences) ->
  valueSum / numberOfOccurrences

getZ: (x,mean,standardDerivation) ->
  (x-mean)/standardDerivation

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

drawNormalCurve: (data, width, height, _graph) ->

  toolTipElement = _graph.append('div')
  .attr('class', 'tooltipGauss')
  .attr('position', 'absolute')
  .attr('width', 15)
  .attr('height', 10)

  showToolTip: (value, positionX, positionY) ->
    toolTipElement.style('display', 'block')
    toolTipElement.style('top', positionY+10+"px")
    toolTipElement.style('left', positionX+10+"px")
    toolTipElement.innerHTML = " Z = "+value

  hideToolTip: () ->
    toolTipElement.style('display', 'none')
    toolTipElement.innerHTML = " "

  console.log extract(data, "x")
  sample = sort(getRandomValueArray(extract(data,"x")))
  sum = getSum(sample)
  min = sample[0]
  max = sample[sample.length - 1]
  mean = getMean(sum, sample.length)
  variance = getVariance(sample, mean)
  standardDerivation =  Math.sqrt(variance)
  rightBound = getRightBound(mean, standardDerivation)
  leftBound = getLeftBound(mean,standardDerivation)
  bottomBound = 0
  topBound = 1/(standardDerivation*Math.sqrt(Math.PI*2))
  gaussianCurveData = getGaussianFunctionPoints(standardDerivation,mean,variance,leftBound,rightBound)
  radiusCoef = 5

  xScale = d3.scale.linear().range([0, width]).domain([leftBound, rightBound])
  yScale = d3.scale.linear().range([height, 0]).domain([bottomBound, topBound])

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
  .on('mousemove', (d) -> showToolTip(getZ(xScale.invert(d3.event.x),mean,standardDerivation).toLocaleString(),d3.event.x,d3.event.y))
  .on('mouseout', (d) -> hideToolTip())
  .attr('fill', "aquamarine")
  #      .style("opacity", .2)

  _graph.append("svg:g")
  .attr("class", "x axis")
  .attr("transform", "translate(0," + (height) + ")")
  .call(xAxis)

  _graph.append("svg:g")
  .attr("class", "y axis")
  .attr("transform", "translate(" + (xScale(mean)) + ",0)")
  .call(yAxis)

  _graph.append("svg:g")
  .append("text")      #text label for the x axis
  .attr("x", width/2 + width/4  )
  .attr("y", 20  )
  .style("text-anchor", "middle")
  .style("fill", "white")
#      .text(seriesName)

# Weighted Values
#      _graph.selectAll("circle")
#      .data(getWeightedValues(sample)).enter().append("circle")
#      #text label for the x axis
#      .attr("cx", (d) -> xScale(d.value))
#      .attr("cy", height)
#      .attr("r", (d) -> radiusCoef)
#      .style("fill","red")
#      .style("opacity",.5)
