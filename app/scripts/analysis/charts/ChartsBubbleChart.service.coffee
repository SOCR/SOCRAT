'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBubbleChart extends BaseService
  
  initialize: ->

  drawBubble: (ranges,width,height,_graph,data,gdata,container) ->
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

    zIsNumber = !isNaN(data[0].z)
    rValue = 0
    if(zIsNumber)
      r = d3.scale.linear()
      .domain([d3.min(data, (d)-> parseFloat d.z), d3.max(data, (d)-> parseFloat d.z)])
      .range([3,15])
      rValue = (d) -> parseFloat d.z
    else
      r = d3.scale.linear()
      .domain([5, 5])
      .range([3,15])
      rValue = (d) -> d.z
      
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
    _graph.append("g")
    .attr("class", "x axis")
    .attr('transform', 'translate(0,' + (height-padding) + ')')
    .call xAxis
    .style('font-size', '16px')
    
    # y axis
    _graph.append("g")
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

    # create circle
    counts_z = count(data) # counts the number for each z variable
    
    circles = _graph.selectAll('.circle')
    .data(data)
    .enter().append('circle')
    .attr('fill',
      if(zIsNumber)
        'yellow'
      else
        (d) -> color(d.z))
    .attr('opacity', '0.7')
    .attr('stroke',
      if(zIsNumber)
        'orange'
      else
        (d) -> color(d.z))
    .attr('stroke-width', '2px')
    .attr('cx', (d) -> x d.x)
    .attr('cy', (d) -> y d.y)
    .attr('r', (d) -> counts_z[d.z])
    
    tooltip = container
    .append('div')
    .attr('class', 'tooltip')
    
    circles.on('mouseover', (d) ->
      radius = () -> 
        return counts_z[rValue(d)]
      tooltip.transition().duration(200).style('opacity', .9)
      tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">' + 'Counts ' + radius +'</div>')
      .style('left', d3.select(this).attr('cx') + 'px').style('top', d3.select(this).attr('cy') + 'px'))
      .on('mouseout', () ->
        tooltip. transition().duration(500).style('opacity', 0))
