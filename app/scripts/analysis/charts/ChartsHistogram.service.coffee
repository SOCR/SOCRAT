'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsHistogram extends BaseService

  initialize: ->

  plotHist: (bins, container, arr, _graph, gdata, x, height, width) ->
    $('#slidertext').remove()
    container.append('text').attr('id', 'slidertext').text('Bin Slider: '+bins).attr('position','relative').attr('left', '50px')
    dataHist = d3.layout.histogram().bins(bins)(arr)

    y = d3.scale.linear().domain([0, d3.max dataHist.map (i) -> i.length]).range([height, 0])

    yAxis = d3.svg.axis().scale(y).orient("left")
    xAxis = d3.svg.axis().scale(x).orient("bottom")

    getColor = d3.scale.category10()

    _graph.selectAll('g').remove()
    _graph.select('.x axis').remove()
    _graph.select('.y axis').remove()

    # x axis
    _graph.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call xAxis
    .append('text')
    .attr('class', 'label')
    .attr('transform', 'translate(' + (width / 2) + ',' + 40 + ')')
    .attr("stroke-width", 0.5)
    .text gdata.xLab.value

    # y axis
    _graph.append("g")
    .attr("class", "y axis")
    .call(yAxis)
    .append("text")
    .attr('class', 'label')
    .attr("transform", "rotate(-90)")
    .attr('y', -50 )
    .attr('x', -(height / 2))
    .attr("dy", ".71em")
    .attr("stroke-width", 0.5)
    .text "Count"

    bar = _graph.selectAll('.bar')
    .data(dataHist)

    bar.enter()
    .append("g")

    rect_width = width / bins
    bar.append('rect')
    .attr('x', (d) -> x d.x)
    .attr('y', (d) -> y d.y)
    .attr('width', rect_width)
    .attr('height', (d) -> height - y d.y)
    .attr("stroke", "white")
    .attr("stroke-width", 1)
    .style('fill', getColor(0))
    .on('mouseover', () -> d3.select(this).transition().style('fill', getColor(1)))
    .on('mouseout', () -> d3.select(this).transition().style('fill', getColor(0)))

    bar.append('text')
    .attr('x', (d) -> x d.x)
    .attr('y', (d) -> y d.y)
    .attr('dx', (d) -> .5 * rect_width)
    .attr('dy', '20px')
    .attr('fill', '#fff')
    .attr('text-anchor', 'middle')
    .attr('z-index', 1)
    .text (d) -> d.y

  drawHist: (_graph, data, container, gdata, width, height, ranges) ->

    bins = 5
    arr = data.map (d) -> parseFloat d.x
    x = d3.scale.linear().domain([ranges.xMin, ranges.xMax]).range([0, width])

    @plotHist bins, container, arr, _graph, gdata, x, height, width

    #pre-set value of slider
    container.append('div').attr('id', 'slider')
    $slider = $("#slider")
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
      @plotHist bins, container, arr, _graph, gdata, x, height, width
