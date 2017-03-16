'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsHistogram extends BaseService

  initialize: ->

  plotHist: (bins, container, arr, _graph, gdata, x, height, width, data) ->
    console.log("Plotting histogram")
    # slider
    $('#slidertext').remove()
    container.append('text').attr('id', 'slidertext').text('Bin Slider: '+bins).attr('position','relative').attr('left', '50px')
    dataHist = d3.layout.histogram().bins(bins)(arr)

    _graph.selectAll('g').remove()
    _graph.select('.x axis').remove()
    _graph.select('.y axis').remove()

    padding = 50
    x = d3.scale.linear().range([ padding, width - padding ])
    y = d3.scale.linear().range([ height - padding, padding ])

    console.log "bins"
    console.log bins
    console.log "arr"
    console.log arr
    console.log "data"
    console.log data

    x.domain([d3.min(data, (d)->parseFloat d.x), d3.max(data, (d)->parseFloat d.x)])
    y.domain([0, (d3.max dataHist.map (i) -> i.length)])

    yAxis = d3.svg.axis().scale(y).orient("left")
    xAxis = d3.svg.axis().scale(x).orient("bottom")

    getColor = d3.scale.category10()

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
    .on('mouseover', () -> d3.select(this).transition().style('fill', getColor(1)))
    .on('mouseout', () -> d3.select(this).transition().style('fill', getColor(0)))

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
    @plotHist bins, container, arr, _graph, gdata, x, height, width, data

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
      @plotHist bins, container, arr, _graph, gdata, x, height, width, data
