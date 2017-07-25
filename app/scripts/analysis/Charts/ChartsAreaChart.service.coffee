'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsAreaChart extends BaseService

  initialize: ->

  drawArea: (height,width,_graph, data,gdata) ->
  #      parseDate = d3.time.format("%d-%b-%y").parse

    for d in data
      d.x = new Date d.x
      d.y = +d.y
    x = d3.time.scale().range([ 0, width ])
    y = d3.scale.linear().range([ height, 0 ])
    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")
    area = d3.svg.area().x((d) ->
      x d.x
    ).y0(height).y1((d) ->
      y d.y
    )
    #  svg = d3.select("body").append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    x.domain d3.extent(data, (d) ->
      d.x
    )
    y.domain [ 0, d3.max(data, (d) ->
      d.y
    ) ]
    _graph.append("path")
    .datum(data)
    .attr("class", "area")
    .attr "d", area
    _graph.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call xAxis

    _graph.append("g")
    .attr("class", "y axis")
    .call(yAxis).append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 6).attr("dy", ".71em")
    .style("text-anchor", "end")
    .text gdata.yLab.value
