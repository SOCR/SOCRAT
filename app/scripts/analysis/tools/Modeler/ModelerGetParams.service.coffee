'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class GetParams extends BaseService

  initialize: ->
    @distanceFromMean = 5

  extract: (data, variable) ->
    tmp = []
    for d in data
      tmp.push +d[variable]
    tmp

  getRightBound: (middle,step) ->
    middle + step * @distanceFromMean

  getLeftBound: (middle,step) ->
    middle - step * @distanceFromMean

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
    for i in [leftBound...rightBound] by .1
      data.push
        x: i
        y:(1 / (std * Math.sqrt(Math.PI * 2))) * Math.exp(-(Math.pow(i - mean, 2) / (2 * variance)))
    console.log(data)
    data

  getMedian = (values)=>
    values.sort  (a,b)=> return a - b
    half = Math.floor values.length/2
    if values.length % 2
      return values[half]
    else
      return (values[half-1] + values[half]) / 2.0


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


  #error function
  erf: (x) ->
    p = 0.3275911
    a1 = 0.254829592
    a2 = -0.284496736
    a3 = 1.421413741
    a4 = -1.453152027
    a5 = 1.061405429
    x0 = Math.abs(x)
    t = 1 / (1 + p * x0)
    #y = 1 - ((a1 * t + a2 * t ** 2 + a3 * t ** 3 + a4 * t ** 4 + a5 * t ** 5) * Math.exp(-x ** 2))
    y = 1 - (a1 * t + a2 * Math.pow(t, 2) + a3 * Math.pow(t, 3) + a4 * Math.pow(t, 4) + a5 * Math.pow(t, 5)) * Math.exp(-Math.pow(x, 2))
    
    if x >= 0
      y
    else
      -y


  getParams:(data) ->
    data = data.dataPoints
    data = data.map (row) ->
      x: row[0]
      y: row[1]
      z: row[2]

    console.log @extract(data, "x")
    console.log("Within the modeler GetParams")
    sample = @sort(@getRandomValueArray(@extract(data,"x")))
    sum = @getSum(sample)
    min = sample[0]
    max = sample[sample.length - 1]
    mean = @getMean(sum, sample.length)


    median = getMedian(sample)
    console.log("Sample mean: " + mean)
    variance = @getVariance(sample, mean)
    standardDerivation =  Math.sqrt(variance)
    rightBound = @getRightBound(mean, standardDerivation)
    leftBound = @getLeftBound(mean,standardDerivation)
    bottomBound = 0
    topBound = 1 / (standardDerivation * Math.sqrt(Math.PI * 2))
    #gaussianCurveData = @getGaussianFunctionPoints(standardDerivation,mean,variance,leftBound,rightBound)
    radiusCoef = 5


    mean = parseFloat(mean.toFixed(2))
    variance = parseFloat(variance.toFixed(2))
    median = parseFloat(median.toFixed(2))
    standardDerivation = parseFloat(standardDerivation.toFixed(2))

    


    return stats =
      mean: mean
      variance: variance
      median: median
      standardDev: standardDerivation
      leftBound: leftBound
      rightBound: rightBound
      topBound: topBound
      bottomBound: bottomBound
      xMin: min
      xMax: max
      scale: 1
      location: mean
      gamma: 1
      A: mean / (2* Math.sqrt(2/ Math.PI)).toFixed(2)




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

    console.log @extract(data, "x")
    console.log("Within the modeler GetParams")
    sample = @sort(@getRandomValueArray(@extract(data,"x")))
    sum = @getSum(sample)
    min = sample[0]
    max = sample[sample.length - 1]
    mean = @getMean(sum, sample.length)
    variance = @getVariance(sample, mean)
    standardDerivation =  Math.sqrt(variance)
    rightBound = @getRightBound(mean, standardDerivation)
    leftBound = @getLeftBound(mean,standardDerivation)
    bottomBound = 0
    topBound = 1 / (standardDerivation * Math.sqrt(Math.PI * 2))
    gaussianCurveData = @getGaussianFunctionPoints(standardDerivation,mean,variance,leftBound,rightBound)
    radiusCoef = 5

    padding = 50
    xScale = d3.scale.linear().range([0, width]).domain([leftBound, rightBound])
    yScale = d3.scale.linear().range([height-padding, 0]).domain([bottomBound, topBound])

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

    console.log("printing gaussian curve data")
    console.log(gaussianCurveData)


    _graph.append('svg:path')
      .attr('d', lineGen(gaussianCurveData))
      .data([gaussianCurveData])
      .attr('stroke', 'black')
      .attr('stroke-width', 1.5)
      .on('mousemove', (d) -> showToolTip(getZ(xScale.invert(d3.event.x),mean,standardDerivation).toLocaleString(),d3.event.x,d3.event.y))
      .on('mouseout', (d) -> hideToolTip())
      .attr('fill', "none")

    '''
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
      .attr("y", 20  )
      .style("text-anchor", "middle")
      .style("fill", "white")

    # rotate text on x axis
    _graph.selectAll('.x.axis text')
      .attr('transform', (d) ->
      'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
      .style('font-size', '16px')

    # make y axis ticks not intersect with x-axis, ticks on x and y axes
    # appear to be the same size
    _graph.selectAll('.y.axis text')
      .attr('transform', (d) ->
      'translate(' + (this.getBBox().height*-2-5) + ',' + (this.getBBox().height-30) + ')')
      .style('font-size', '15.7px')
    '''





  '''
  kernelDensityEstimator: (kernel, x) ->
    (sample) ->
      x.map (x) ->
      {
        x: x
        y: d3.mean(sample, (v) ->
          kernel x - v
        )
      }
  '''

  getMeanByAccessor: (array, f) ->
    s = 0
    n = array.length
    a = undefined
    i = -1
    j = n
    if f == null
      while ++i < n
        if !isNaN(a = number(array[i]))
          s += a
        else
          --j
    else
      while ++i < n
        if !isNaN(a = number(f(array[i], i, array)))
          s += a
        else
          --j
    if j
      return s / j
    return

  toObject: (arr) ->
    rv = {}
    i = 0
    while i < arr.length
      if arr[i] != undefined
        value = ''
        if i == 0
          value = 'x'
        else
          value = 'y'

        rv[value] = arr[i]
      ++i
    rv

  kernelDensityEstimator: (kernel, x) ->
    (sample) ->
      x.map (x) ->

        mean = d3.mean(sample, (v) ->
          kernel(x - v)
        )

        [
          x
          d3.mean(sample, (v) ->
            kernel x - v
          )
        ]

  isEven = (n) ->
    if n % 2 == 0
      true
    else
      false

  isOdd = (n) ->
    if (n - 1) % 2 == 0
      true
    else
      false

  #Sign functon

  sgn = (x) ->
    if x > 0
      1
    else if x < 0
      -1
    else
      0

  #Sorting functions

  ascend = (a, b) ->
    a - b

  descend = (a, b) ->
    b - a

  #Generalzied power function

  genPow = (a, n, b) ->
    p = 1
    i = 0
    while i < n
      p = p * (a + i * b)
      i++
    p

  #Rising power funtion

  risePow = (a, n) ->
    genPow a, n, 1

  #Falling power function

  perm = (n, k) ->
    p = 1
    i = 0
    while i < k
      p = p * (n - i)
      i++
    p

  #Factorial function

  factorial = (n) ->
    perm n, n

  #Binomial coefficient

  binomial = (n, k) ->
    if k < 0 or k > n
      0
    else
      p = 1
      i = 0
      while i < k
        p = p * (n - i) / (k - i)
        i++
      p

  #Polylogarithm function

  polyLog = (a, x) ->
    sum = 0
    k = 1
    e = 0.0001
    while x ** k / k ** a > e
      sum = sum + x ** k / k ** a
      k++
    sum
  