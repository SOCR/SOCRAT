'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsTreemap extends BaseService
  
  initialize: ->

  drawTreemap: (svg, width, height, container, data) ->
      maxDepth = 5
      sliderValue = 3

      sliderBar = container.append('input')
      .attr('id', 'slider')
      .attr('type', 'range')
      .attr('min', '1')
      .attr('max', maxDepth)
      .attr('step', '1')
      .attr('value', '3')

      plotTreemap = (sliderValue, maxDepth) ->
        color = d3.scale.category10()
        depthRestriction = sliderValue
        treemap = d3.layout.treemap()
        .size([width, height])
        .padding(4)
        .sticky(true)
        .value((d) ->d.size)

        filteredData = treemap.nodes(data).filter((d) -> d.depth < depthRestriction)
        leafNodes = treemap.nodes(data).filter((d) -> !d.children) # get all the leaf children
        findMaxDepth = (d) ->
          tmpMaxDepth = 0
          for i in [0..d.length-1] by 1
            if d[i].depth > tmpMaxDepth then tmpMaxDepth = d[i].depth
          return tmpMaxDepth
        maxDepth = findMaxDepth(leafNodes) + 1

        sliderBar.attr('max', maxDepth)

        node = svg.append('g')
        .selectAll('g.node')
        .data(filteredData)
        .enter().append('g')
        .attr('class', 'node')
        .attr('transform', (d) -> 'translate(' + d.x + ',' + d.y + ')')
        .append('svg')
        .attr('class', 'inner-node')
        .attr('width', (d) -> Math.max(0.01, d.dx - 1))
        .attr('height', (d) -> Math.max(0.01, d.dy - 1))
        .on('click', (d) -> if d.url then window.open(d.url))


        node.append('rect')
        .attr('width', (d) -> Math.max(0.01, d.dx - 1))
        .attr('height', (d) -> Math.max(0.01, d.dy - 1))
        .style('fill', (d) -> if d.children then color(d.name) else color(d.parent.name))
        .style('stroke', 'white')
        .style('stroke-width', '1px')
        .on('mouseover', () ->
          d3.select(@).append('title')
          .text((d) ->
            'Parent: ' + d.parent.name + '\n' +
              'Name: ' + d.name + '\n' +
              'Depth: ' + d.depth
          )
          d3.select(@)
          .style('stroke', 'black')
          .style('stroke-width', '3px')
        )
        .on('mouseout', () ->
          d3.select(@)
          .style('stroke', 'white')
          .style('stroke-width', '1px')
          d3.select(@).select('title').remove()
        )

        # update slider value
        $('#sliderText').remove()

        container.append('text')
        .attr('id', 'sliderText')
        .text('Treemap depth: ' + sliderValue)
        .attr('position', 'relative')
        .attr('left', '50px')

      plotTreemap(sliderValue, maxDepth) # default value of treemap depth

      d3.select('#slider')
      .on('change', () ->
        sliderValue = parseInt this.value
        plotTreemap(sliderValue, maxDepth)
      )
