'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBubbleChart extends BaseService
  
  initialize: ->

  drawBubble: (ranges,width,height,_graph,data,gdata,container) ->
    #testing
    nest = d3.nest().key (d) -> d.z

    x = d3.scale.linear().domain([ranges.xMin,ranges.xMax]).range([ 0, width ])
    y = d3.scale.linear().domain([ranges.yMin,ranges.yMax]).range([ height, 0 ])
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left')

    zIsNumber = !isNaN(data[0].z)

    r = 0
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

    tooltip = container
    .append('div')
    .attr('class', 'tooltip')

    color = d3.scale.category10()

    # x axis
    _graph.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis)
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
    .text gdata.yLab.value

    # create circle
    _graph.selectAll('.circle')
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
    .attr('r', (d) ->
      if(zIsNumber) # if d.z is number, use d.z as radius
        r d.z
      else # else, set radius to be 8
        8)
    .on('mouseover', (d) ->
      tooltip.transition().duration(200).style('opacity', .9)
      tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">'+gdata.zLab.value+': '+ rValue(d)+'</div>')
      .style('left', d3.select(this).attr('cx') + 'px').style('top', d3.select(this).attr('cy') + 'px'))
    .on('mouseout', () ->
      tooltip. transition().duration(500).style('opacity', 0))
