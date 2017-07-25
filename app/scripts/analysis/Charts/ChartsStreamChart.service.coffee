'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsStreamChart extends BaseService

  initialize: ->

  streamGraph: (data,ranges,width,height,_graph,scheme) ->
  #      parseDate = d3.time.format("%d-%b-%y").parse
  #console.log parseDate data[0].x
  
    x = d3.time.scale()
    .range([0, width])
  
    y = d3.scale.linear()
    .range([height-10, 0])
  
    z = d3.scale.ordinal()
    .range(scheme) #["#045A8D", "#2B8CBE", "#74A9CF", "#A6BDDB", "#D0D1E6", "#F1EEF6"])
  
    console.log scheme
  
  
    xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom")
    #      .ticks(d3.time.weeks)
  
    yAxis = d3.svg.axis()
    .scale(y)
  
    stack = d3.layout.stack()
    .offset("silhouette")
    .values((d) -> d.values)
    .x((d) -> d.x)
    .y((d) -> d.y)
  
    nest = d3.nest().key (d) -> d.z
  
    console.log data
  
    area = d3.svg.area()
    .interpolate("cardinal")
    .x((d)-> x(d.x))
    .y0((d)-> y(d.y0))
    .y1((d)->y(d.y0 + d.y))
  
    for d in data
      d.x = new Date d.x
      d.y = +d.y
  
    console.log nest.entries(data)
  
    layers = stack(nest.entries(data))
  
    x.domain(d3.extent(data, (d)-> d.x))
    y.domain([0, d3.max(data, (d) -> d.y0 + d.y)])
  
    console.log layers
  
    _graph.selectAll(".layer")
    .data(layers)
    .enter().append("path")
    .attr("class", "layer")
    .attr("d", (d) -> area(d.values))
    .style("fill", (d, i) ->z(i))
  
    _graph.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis)
  
    _graph.append("g")
    .attr("class", "y axis")
    .attr("transform", "translate(" + width + ", 0)")
    .call(yAxis.orient("right"))
  
    _graph.append("g")
    .attr("class", "y axis")
    .call(yAxis.orient("left"))
