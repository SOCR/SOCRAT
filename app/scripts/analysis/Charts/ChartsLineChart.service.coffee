'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsLineChart extends BaseService

  initialize: ->

  lineChart: (data,ranges,width,height,_graph, gdata,container) ->
  #      formatDate = d3.time.format("%d-%b-%y")
    bisectDate = d3.bisector((d) -> d.x).left
  
    for d in data
      d.x = new Date d.x
      d.y = +d.y
  
    x = d3.time.scale()
    .range([0, width])
  
    y = d3.scale.linear()
    .range([height, 0])
  
    xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom")
  
    yAxis = d3.svg.axis()
    .scale(y)
    .orient("left")
  
    line = d3.svg.line()
    .x((d) -> x(d.x))
    .y((d) -> y(d.y))
  
    focus = _graph.append("g")
    .style("display", "none")
  
    x.domain(d3.extent(data,  (d) -> d.x))
    y.domain(d3.extent(data,  (d) -> d.y))
  
    _graph.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis)
  
    _graph.append("g")
    .attr("class", "y axis")
    .call(yAxis)
    .append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 6)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .text gdata.yLab.value
  
    _graph.append("path")
    .datum(data)
    .attr("class", "line")
    .attr("d", line)
  
    #add tooltip
    focus.append("circle")
    .attr("class", "y")
    .style("fill", "white")
    .style("stroke", "steelblue")
    .style("stroke-width", "3px")
    .attr("r", 8)
  
  
    #point of label
    d0 = null
    val = null
  
    tooltip = container.append('div')
    .attr('class', 'tooltip')
  
    mousemove: () ->
      x0 = x.invert(d3.mouse(this)[0])
  
      i = bisectDate(data, x0, 1)
      #        console.log x0, i
      d0 = data[i - 1]
      d1 = data[i]
      d = x0 - d0.x > d1.x - x0 ? d1 : d0
      console.log d
      focus.select("circle.y")
      .attr("transform","translate(" + x(d0.x) + "," + y(d0.y) + ")")
      val = y.invert(d3.mouse(this)[0])
      tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">'+val+'</div>').style('top', height - y.invert(d3.mouse(this)[1]) + 'px').style('left', x.invert(d3.mouse(this)[0]) + 'px')
  
  
    _graph.append("rect")
    .attr("height", height)
    .attr("width", width)
    .style("fill", "none")
    .style("pointer-events", "all")
    .on("mouseover", () ->
      focus.style("display", null)
      console.log val
      tooltip.transition().duration(200).style('opacity', .9)
  
    )
    .on("mouseout", () ->
      focus.style("display", "none")
      tooltip.transition().duration(500).style('opacity', 0)
    )
    .on("mousemove", mousemove)
