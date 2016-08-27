'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsStackedBar extends BaseService

  initialize: ->

  stackedBar: (data,ranges,width,height,_graph, gdata,container) ->

    x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1)

    y = d3.scale.linear()
    .rangeRound([height, 0])
    #
    #      z = d3.scale.ordinal()
    #        .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"])

    xAxis = d3.svg.axis()
    .scale(x)
    . orient("bottom");

    yAxis = d3.svg.axis()
    .scale(y)
    .orient("left")
    .tickFormat(d3.format(".2s"))

    tooltip = container
    .append('div')
    .attr('class', 'tooltip')

    #      x = d3.scale.ordinal().rangeRoundBands([0, width-50])
    #      y = d3.scale.linear().range([0, height-50])
    z = d3.scale.ordinal()
    .domain([gdata.xLab.value,gdata.yLab.value,gdata.zLab.value])
    .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"])

    newData = []
    for d in data
      obj = {}
      obj[gdata.xLab.value] = +d.x
      obj[gdata.yLab.value] = +d.y
      obj[gdata.zLab.value] = +d.z
      newData.push obj

    for d in newData
      y0 = 0
      d.ages = z.domain().map (name) ->
        name: name
        y0: y0
        y1: y0 += +d[name]
      d.total = d.ages[d.ages.length - 1].y1

    newData.sort (a,b) -> b.total - a.total

    x.domain(newData.map (d) -> d[gdata.xLab.value])
    y.domain([0, d3.max(newData, (d) -> d.total)])

    _graph.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis)

    _graph.append("g")
    .attr("class", "y axis")
    .call(yAxis)

    state = _graph.selectAll(".state")
    .data(newData)
    .enter().append("g")
    .attr("class", "g")
    .attr("transform", (d) -> "translate(" + x(d[gdata.xLab.value]) + ",0)")

    state.selectAll("rect")
    .data((d) -> d.ages)
    .enter().append("rect")
    .attr("width", x.rangeBand())
    .attr("y", (d) -> y(d.y1))
    .attr("height", (d) -> y(d.y0) - y(d.y1))
    .style("fill", (d) -> z(d.name))
    .on('mouseover', (d)->
      tooltip.transition().duration(200).style('opacity', .9)
      tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">'+d.name+ ' ' +d.y1+'</div>')
      .style('left', d3.select(this).attr('x') + 'px').style('top', 50))
    .on('mouseout', (d)->
      tooltip.transition().duration(500).style('opacity', 0))

    console.log newData
