'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsScatterPlot extends BaseService
  
  initialize: ->

  drawScatterPlot: (data,ranges,width,height,_graph,container,gdata) ->
    padding = 50
    x = d3.scale.linear().domain([ranges.xMin,ranges.xMax]).range([ padding, width-padding ])
    y = d3.scale.linear().domain([ranges.yMin,ranges.yMax]).range([ height-padding, padding ])
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left')

    # values
    xValue = (d)->parseFloat d.x
    yValue = (d)->parseFloat d.y

    # map dot coordination
    xMap = (d)-> x xValue(d)
    yMap = (d)-> y yValue(d)

    # x axis
    _graph.append("g")
    .attr("class", "x axis")
    .attr('transform', 'translate(0,' + (height - padding) + ')')
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
