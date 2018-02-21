'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsHistogram extends BaseService

  initialize: ->

  @median = null;
  @mean = null;
  getMedian: (arr) ->
    arr.sort  (a,b) -> return a - b
    half = Math.floor arr.length/2
    if arr.length % 2
      return arr[half]
    else
      return (arr[half-1] + arr[half]) / 2.0

  getMean: (arr) ->
    sum = 0
    sum += a for a in arr
    return (sum/arr.length).toFixed 2



  plotHist: (bins, container, arr, _graph, gdata, x, height, width, data, median, mean) ->

#    tooltip
    $('#tooltip').remove();
    # slider
    $('#slidertext').remove()
    container.append('text').attr('id', 'slidertext').text('Bin Slider: '+bins).attr('position','relative').attr('left', '50px')
    dataHist = d3.layout.histogram().bins(bins)(arr)
    console.log dataHist #array for each bin, each array has all data points

    #create array of objects that store mean and median of each set
    stats = []
    for a in dataHist
      stats.push({mean: @getMean(a), median: @getMedian(a)})

    console.log stats

    xMean = (d, i) -> stats[i].mean
    xMedian = (d, i) -> stats[i].median
    xLength = (d, i) -> dataHist[i].length

    _graph.selectAll('g').remove()
    _graph.select('.x axis').remove()
    _graph.select('.y axis').remove()

    padding = 50
    x = d3.scale.linear().range([ padding, width - padding ])
    y = d3.scale.linear().range([ height - padding, padding ])

    x.domain([d3.min(data, (d)->parseFloat d.x), d3.max(data, (d)->parseFloat d.x)])
    y.domain([0, (d3.max dataHist.map (i) -> i.length)])

    yAxis = d3.svg.axis().scale(y).orient("left")
    xAxis = d3.svg.axis().scale(x).orient("bottom")

    getColor = d3.scale.category10()



    # add the tooltip area to the webpage
    tooltip = container
      .append('div')
      .attr('class', 'tooltip')
      .attr('id', 'tooltip')

    # x axis
    _graph.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + (height - padding) + ")")
    .call xAxis
    .style('font-size', '16px')

    # y axis
    _graph.append("g")
    .attr("class", "y axis")
    .attr('transform', 'translate(' + padding + ',0)' )
    .call(yAxis)
    .style('font-size', '16px')

    # make x y axis thin
    _graph.selectAll('.x.axis path')
    .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
    _graph.selectAll('.y.axis path')
    .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})

    # rotate text on x axis
    _graph.selectAll('.x.axis text')
    .attr('transform', (d) ->
       'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
    .style('font-size', '16px')

    # Title on x-axis
    _graph.append('text')
    .attr('class', 'label')
    .attr('text-anchor', 'middle')
    .attr('transform', 'translate(' + width + ',' + (height-padding/2) + ')')
    .text gdata.xLab.value

    # Title on y-axis
    _graph.append("text")
    .attr('class', 'label')
    .attr('text-anchor', 'middle')
    .attr('transform', 'translate(0,' + padding/2 + ')')
    .text "Counts"

    # bar elements
    bar = _graph.selectAll('.bar')
    .data(dataHist)

    bar.enter()
    .append("g")

    rect_width = (width - 2*padding)/bins
    bar.append('rect')
    .attr('x', (d) -> x d.x)
    .attr('y', (d) -> y d.y)
    .attr('width', rect_width)
    .attr('height', (d) -> Math.abs(height - y d.y) - padding)
    .attr("stroke", "white")
    .attr("stroke-width", 1)
    .style('fill', getColor(0))
    .on('mouseover', (d, i) ->
        d3.select(this)
          .transition()
          .style('fill', getColor(1))


        tooltip.transition().duration(200).style('opacity', .9)


        tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">'+gdata.xLab.value+'</br>'+'Median: '+ xMedian(d,i)+'</br>'+'Mean: '+xMean(d,i)+'</br>'+"N: "+xLength(d, i)+'</div>')
          .attr('value', stats[i].mean)
          .style('display', 'block')
          .style('opacity', .4)
          .style('padding', 2)
          .style('border', 0)
          .style('border-radius', 8)
          .style('left', d3.select(this).attr('x') + 'px')
          .style('top', d3.select(this).attr('y') + 'px')
#          .text("Mean1: "+ stats[i].mean + '</br>'+ "Median: " + stats[i].median)

#        tooltip.append("p")
#          .text("Mean: "+ stats[i].mean)
#          .append("br")
#          .append("p")
#          .text("Median: "+ stats[i].median)

#        tooltip.append("/br")

    )
    .on('mouseout', () -> 
      d3.select(this).transition().style('fill', getColor(0))
      tooltip.style('display', 'none')
    )

    bar.append('text')
    .attr('x', (d) -> x d.x)
    .attr('y', (d) -> (y d.y) - 25)
    .attr('dx', (d) -> .5 * rect_width)
    .attr('dy', '20px')
    .attr('fill', 'black')
    .attr('text-anchor', 'middle')
    .attr('z-index', 1)
    .text (d) -> d.y

  drawHist: (_graph, data, container, gdata, width, height, ranges) ->
    #pre-set value of slider
    container.append('div').attr('id', 'slider')
    $slider = $("#slider")
    bins = 5
    arr = data.map (d) -> parseFloat d.x
    median = @getMedian(arr)
    mean = @getMean(arr)
    @plotHist bins, container, arr, _graph, gdata, x, height, width, data, median, mean

    if $slider.length > 0
      $slider.slider(
        min: 1
        max: 10
        value: 5
        orientation: "horizontal"
        range: "min"
        change: ->
      ).addSliderSegments($slider.slider("option").max)
    $slider.on "slidechange", (event, ui) =>
      bins = parseInt ui.value
#      tooltip.html()
      @plotHist bins, container, arr, _graph, gdata, x, height, width, data, median, mean
