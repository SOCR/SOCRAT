'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBivariateLineChart extends BaseService

  initialize: ->

  bivariateChart: (height,width,_graph, data, gdata) ->
  #      parseDate = d3.time.format("%d-%b-%y").parse

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

    area = d3.svg.area()
    .x((d) -> x(d.x))
    .y0((d) -> y(d.y))
    .y1((d) -> y(d.z))

    for d in data
      d.x = new Date d.x
      d.y = +d.y
      d.z = +d.z

    x.domain(d3.extent data, (d) -> d.x)
    y.domain([d3.min(data, (d) -> d.y), d3.max(data, (d) -> d.z)])

    console.log y.domain

    _graph.append("path")
    .datum(data)
    .attr("class", "area")
    .attr("d", area)
    .style('fill', 'steelblue')

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
