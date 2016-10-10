'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsScatterPlot extends BaseService
  
  initialize: ->

  drawScatterPlot: (data,ranges,width,height,_graph,container,gdata) ->

    x = d3.scale.linear().domain([ranges.xMin,ranges.xMax]).range([ 0, width ])
    y = d3.scale.linear().domain([ranges.yMin,ranges.yMax]).range([ height, 0 ])
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left')

    # values
    xValue = (d)->parseFloat d.x
    yValue = (d)->parseFloat d.y

    # map dot coordination
    xMap = (d)-> x xValue(d)
    yMap = (d)-> y yValue(d)

    # set up fill color
    #cValue = (d)-> d.y
    #color = d3.scale.category10()

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
    .text gdata.yLab.value

    # add the tooltip area to the webpage
    tooltip = container
    .append('div')
    .attr('class', 'tooltip')

    # draw dots
    _graph.selectAll('.dot')
    .data(data)
    .enter().append('circle')
    .attr('class', 'dot')
    .attr('r', 5)
    .attr('cx', xMap)
    .attr('cy', yMap)
    .style('fill', 'DodgerBlue')
    .attr('opacity', '0.5')
    .on('mouseover', (d)->
      tooltip.transition().duration(200).style('opacity', .9)
      tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">(' + xValue(d)+ ',' + yValue(d) + ')</div>')
      .style('left', d3.select(this).attr('cx') + 'px').style('top', d3.select(this).attr('cy') + 'px'))
    .on('mouseout', (d)->
      tooltip.transition().duration(500).style('opacity', 0))
