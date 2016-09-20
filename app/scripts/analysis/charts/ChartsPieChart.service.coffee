'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsPieChart extends BaseService

  initialize: ->
    @valueSum = 0

  makePieData: (data) ->
    @valueSum = 0
    counts = {}
    if(!isNaN(data[0].x)) # data is number
      pieMax = d3.max(data, (d)-> parseFloat d.x)
      pieMin = d3.min(data, (d)-> parseFloat d.x)
      maxPiePieces = 7  # set magic constant to variable
      rangeInt = Math.ceil((pieMax - pieMin) / maxPiePieces)
      counts = {}
      for val in data
        index = Math.floor((val.x - pieMin) / rangeInt)
        groupName = index + "-" + (index + rangeInt)
        #console.log groupName
        counts[groupName] = counts[groupName] || 0
        counts[groupName]++
        @valueSum++
    else # data is string
      for i in [0..data.length-1] by 1
        currentVar = data[i].x
        counts[currentVar] = counts[currentVar] || 0
        counts[currentVar]++
        @valueSum++
    obj = d3.entries counts
    return obj

  drawPie: (data,width,height,_graph, pie) ->
      radius = Math.min(width, height) / 2
      arc = d3.svg.arc()
      .outerRadius(radius)
      .innerRadius(0)

      if not pie
        arc.innerRadius(radius-60)

      color = d3.scale.category20c()
      arcOver = d3.svg.arc()
      .outerRadius(radius + 10)
      if not pie
        arcOver.innerRadius(radius-50)

      pie = d3.layout.pie()
      .value((d)-> d.value)
      .sort(null)

      formatted_data = @makePieData data

      arcs = _graph.selectAll(".arc")
      .data(pie(formatted_data))
      .enter()
      .append('g')
      .attr("class", "arc")

      arcs.append('path')
      .attr('d', arc)
      .attr('fill', (d) -> color(d.data.value))
      .on('mouseenter', (d) -> d3.select(this).attr("stroke","white") .transition().attr("d", arcOver).attr("stroke-width",3))
      .on('mouseleave', (d) -> d3.select(this).transition().attr('d', arc).attr("stroke", "none"))

      arcs.append('text')
      .attr('id','tooltip')
      .attr('transform', (d) -> 'translate('+arc.centroid(d)+')')
      .attr('text-anchor', 'middle')
      .text (d) -> d.data.key + ': ' + parseFloat(100*d.data.value/@valueSum).toFixed(2) + '%'

