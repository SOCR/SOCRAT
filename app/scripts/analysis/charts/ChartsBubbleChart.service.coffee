'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBubbleChart extends BaseService

  initialize: ->

  drawBubble: (width,height,_graph,data,gdata,container,ranges) ->

    #testing
    #nest = d3.nest().key (d) -> d.z

    # Function count.
    # Parameter array has data structure the same as 'data'
    # Return a hash table.
    #   key: each element in the parameter array
    #   value: the count of each element
    CateVar = { X:1, Y:2, Z:3, C:4 }
    count = (array, variable) ->
      counts = {}
      for i in [0..array.length-1] by 1
        currentVar = 0
        switch variable
          when CateVar.X
            currentVar = array[i].x
          when CateVar.Y
            currentVar = array[i].y
          when CateVar.Z
            currentVar = array[i].z
          when CateVar.R
            currentVar = array[i].r
        counts[currentVar] = counts[currentVar] || 0
        ++counts[currentVar]
      return counts

    padding = 50

    x_range = ranges.xMax - ranges.xMin
    x_padding = x_range * 0.05


    y_range = ranges.yMax - ranges.yMin
    y_padding = y_range * 0.05


    x = d3.scale.linear().domain([ranges.xMin - x_padding, ranges.xMax + x_padding]).range([ padding, width - padding ])
    y = d3.scale.linear().domain([ranges.yMin - y_padding, ranges.yMax + y_padding]).range([ height - padding, padding ])
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left')

    # Define utilities for creating circles
    yCounts = null
    rCounts = null
    scaleYCount = null
    scaleRCounts = null
    color = null

    if not data[0].y
      yCounts = count(data, CateVar.X)
      min_yCount = d3.min(d3.values(yCounts))
      max_yCount = d3.max(d3.values(yCounts))
      y_countPadding = 1
      if min_yCount == max_yCount or min_yCount == 0
        scaleYCount = d3.scale.linear().domain([0, max_yCount + y_countPadding]).range([ height - padding, padding ])
      else
        scaleYCount = d3.scale.linear().domain([min_yCount - y_countPadding, max_yCount + y_countPadding]).range([ height - padding, padding ])
      yAxis = d3.svg.axis().scale(scaleYCount).orient('left')

    if data[0].z
      color = d3.scale.category20()

    if data[0].r
      rCounts = count(data, CateVar.R) # count the number for each radius variable
      min_rCount = d3.min(d3.values(rCounts))
      max_rCount = d3.max(d3.values(rCounts))
      #scaleRCount = d3.scale.linear().domain([min_rCount, max_rCount]).range([5, 40])

      rRadii = []
      rCountsObj = d3.entries rCounts
      for obj in rCountsObj
        rRadii.push(obj.value)

      rRadii.sort((a, b) -> a - b)
      rRadii = Array.from(new Set(rRadii))
      scaleRCount = d3.scale.ordinal().domain(rRadii).rangePoints([5, 40])


    # x axis
    x_axis = _graph.append("g")
    .attr("class", "x axis")
    .attr('transform', 'translate(0,' + (height-padding) + ')')
    .call xAxis
    .style('font-size', '16px')

    # y axis
    y_axis = _graph.append("g")
    .attr("class", "y axis")
    .attr('transform', 'translate(' + padding + ',0)' )
    .call yAxis
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
    .text(if not data[0].y then 'Counts' else gdata.yLab.value)

    # Show tick lines
    x_axis.selectAll(".x.axis line").style('stroke', 'black')
    y_axis.selectAll(".y.axis line").style('stroke', 'black')

    # Create Circles
    circles = _graph.selectAll('.circle')
    .data(data)
    .enter().append('circle')
    .attr('fill', (d) -> if not data[0].z then 'steelblue' else color(d.z))
    .attr('opacity', '0.6')
    .attr('cx', (d) -> x d.x)
    .attr('cy', (d) -> if data[0].y then y d.y else scaleYCount yCounts[d.x])
    .attr('r', (d) -> if not data[0].r then 10 else scaleRCount rCounts[d.r])

    # Tooltip for Radius
    if data[0].r? # Show tooltip when radius variable is selected
      tooltip = container
      .append('div')
      .attr('class', 'tooltip')

      circles
      .on('mouseover', (d) ->
        radius = () ->
          return rCounts[d.r]
        d3.select(this).attr('opacity', '1').attr('stroke', 'white').attr('stroke-width', '2px')
        tooltip.transition().duration(200).style('opacity', .9)
        tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">' + gdata.rLab.value + ': ' + d.r + ' Counts: ' + radius +'</div>')
        .style('left', d3.select(this).attr('cx') + 'px').style('top', d3.select(this).attr('cy') + 'px')
      )
      .on('mouseout', () ->
        tooltip.transition().duration(500).style('opacity', 0)
        d3.select(this).attr('opacity', '0.6').attr('stroke', 'none')
      )


    # Legend for Color
    if data[0].z?
      legendRectSize = 8
      legendSpacing = 5
      textSize = 11
      horz = width - padding - 2 * legendRectSize
      vert = textSize

      # Legend Title
      _graph.append('text')
      .attr('class', 'label')
      .attr('transform', 'translate(' + horz + ',' + vert + ')')
      .text gdata.zLab.value

      legend = _graph.selectAll('.legend')
      .data(color.domain())
      .enter()
      .append('g')
      .attr('class', 'legend')
      .attr('transform', (d, i) ->
        ht = legendRectSize + legendSpacing # height of each legend
        h = horz
        v = vert + legendRectSize + i * ht
        return 'translate(' + h + ',' + v + ')'
      )

      # Legend rect
      legend.append('rect')
      .attr('width', legendRectSize)
      .attr('height', legendRectSize)
      .style('fill', color)
      .style('stroke', color)

      # Legend Text
      legend.append('text')
      .attr('x', legendRectSize + legendSpacing)
      .attr('y', legendRectSize)
      .text((d) -> d)
      .style('font-size', textSize + 'px')

