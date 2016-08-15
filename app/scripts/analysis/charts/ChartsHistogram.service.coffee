'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsHistogram extends BaseService

  initialize: ->

  drawHist: (_graph,data,container,gdata,width,height,ranges) ->
    container.append('input').attr('id', 'slider').attr('type','range').attr('min', '1').attr('max','10').attr('step', '1').attr('value','5')

    bins = null
    dataHist = null

    arr = data.map (d) -> parseFloat d.x
    x = d3.scale.linear().domain([ranges.xMin, ranges.xMax]).range([0,width])

    plotHist: (bins) ->
      $('#slidertext').remove()
      container.append('text').attr('id', 'slidertext').text('Bin Slider: '+bins).attr('position','relative').attr('left', '50px')
      dataHist = d3.layout.histogram().bins(bins)(arr)

      y = d3.scale.linear().domain([0,d3.max dataHist.map (i) -> i.length]).range([height,0])

      yAxis = d3.svg.axis().scale(y).orient("left")
      xAxis = d3.svg.axis().scale(x).orient("bottom")

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
      .text "Count"

      bar = _graph.selectAll('.bar')
      .data(dataHist)

      bar.enter()
      .append("g")

      rect_width = width/bins
      bar.append('rect')
      .attr('x', (d) -> x d.x)
      .attr('y', (d) -> height - y d.y)
      .attr('width', rect_width)
      .attr('height', (d) -> y d.y)
      .attr("stroke","white")
      .attr("stroke-width",1)
      .on('mouseover', () -> d3.select(this).transition().style('fill', 'orange'))
      .on('mouseout', () -> d3.select(this).transition().style('fill', 'steelblue'))

      bar.append('text')
      .attr('x', (d) -> x d.x)
      .attr('y', (d) -> height - y d.y)
      .attr('dx', (d) -> .5*rect_width)
      .attr('dy', '20px')
      .attr('fill', '#fff')
      .attr('text-anchor', 'middle')
      .attr('z-index', 1)
      .text (d) -> d.y

    plotHist(5) #pre-set value of slider

    d3.select('#slider')
    .on('change', () ->
      bins = parseInt this.value
      plotHist(bins)
    )
