'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBubbleChart extends BaseService
  
  initialize: ->

  drawBubble: (ranges,width,height,_graph,data,gdata,container) ->
    
    if not data[0].y? # y variable is undefined 
      return
    #testing
    nest = d3.nest().key (d) -> d.z

    padding = 50
    
    x_range = ranges.xMax - ranges.xMin
    x_padding = x_range * 0.05
    
    y_range = ranges.yMax - ranges.yMin
    y_padding = y_range * 0.05
    
    x = d3.scale.linear().domain([ranges.xMin - x_padding, ranges.xMax + x_padding]).range([ padding, width - padding])
    y = d3.scale.linear().domain([ranges.yMin - y_padding, ranges.yMax + y_padding]).range([ height - padding, padding ])
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left')
      
    # Function count.
    # Parameter array has data structure the same as 'data' 
    # Return a hash table. 
    #   key: each element in the parameter array
    #   value: the count of each element
    count = (array) ->
      counts = {}
      for i in [0..array.length-1] by 1
        currentVar = array[i].z
        counts[currentVar] = counts[currentVar] || 0
        ++counts[currentVar]
      return counts

    color = d3.scale.category10()

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
    .text gdata.yLab.value
    
    # Show tick lines
    x_axis.selectAll(".x.axis line").style('stroke', 'black')
    y_axis.selectAll(".y.axis line").style('stroke', 'black')

    # Create Circle
    counts = count(data) # counts the number for each z variable
    min_count = d3.min(d3.values(counts))
    max_count = d3.max(d3.values(counts))
    scale = d3.scale.linear().domain([min_count, max_count+10]).range([5, 40])
    
    circles = _graph.selectAll('.circle')
    .data(data)
    .enter().append('circle')
    .attr('fill', (d) -> color(d.c))
    .attr('opacity', '0.6')
    .attr('cx', (d) -> x d.x)
    .attr('cy', (d) -> y d.y)
    .attr('r', (d) -> if not data[0].z then 10 else scale counts[d.z])
    
    # Tooltip
    if data[0].z? # Show tooltip when z variable is selected
      tooltip = container
      .append('div')
      .attr('class', 'tooltip')
    
      circles
      .on('mouseover', (d) ->
        radius = () -> 
          return counts[d.z]
        d3.select(this).attr('opacity', '1').attr('stroke', 'white').attr('stroke-width', '2px')
        tooltip.transition().duration(200).style('opacity', .9)
        tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">' + 'Counts ' + radius +'</div>')
        .style('left', d3.select(this).attr('cx') + 'px').style('top', d3.select(this).attr('cy') + 'px')
      )
      .on('mouseout', () ->
        tooltip.transition().duration(500).style('opacity', 0)
        d3.select(this).attr('opacity', '0.6').attr('stroke', 'none')
      )
    

    # Legend
    if data[0].c?  
      legendRectSize = 8
      legendSpacing = 5
      textSize = 11
      horz = width - padding - 2 * legendRectSize
      vert = textSize
  
      # Legend Title 
      _graph.append('text')
      .attr('class', 'label')
      .attr('transform', 'translate(' + horz + ',' + vert + ')')
      .text gdata.cLab.value
  
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
    
