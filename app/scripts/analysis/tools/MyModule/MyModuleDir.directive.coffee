'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class MyModuleDir extends BaseDirective
  @inject '$parse'

  initialize: ->
    @restrict = 'E'
    @template = "<svg width='100%' height='600'></svg>"
    @replace = true # replace the directive element with the output of the template

    # The link method does the work of setting the directive
    #  up, things like bindings, jquery calls, etc are done in here
    @link = (scope, elem, attr) =>

      MARGIN_LEFT = 40
      MARGIN_TOP = 20

      graph = null
      xScale = null
      yScale = null
      color = null

      svg = d3.select(elem[0])
      graph = svg.append('g').attr('transform', 'translate(' +  MARGIN_LEFT + ',' + MARGIN_TOP + ')')
      color = d3.scale.category10()

      scope.$watch 'mainArea.dataPoints', (newDataPoints) =>
        if newDataPoints
          xDataPoints = (Number(row[0]) for row in newDataPoints)
          yDataPoints = (Number(row[1]) for row in newDataPoints)
          minXDataPoint = d3.min xDataPoints
          maxXDataPoint = d3.max xDataPoints
          minYDataPoint = d3.min yDataPoints
          maxYDataPoint = d3.max yDataPoints
          xScale = d3.scale.linear().domain([minXDataPoint, maxXDataPoint]).range([0, 600])
          yScale = d3.scale.linear().domain([minYDataPoint, maxYDataPoint]).range([0, 500])
          drawDataPoints newDataPoints
      , on


      drawDataPoints = (dataPoints) ->

        pointDots = graph.selectAll('.pointDots').data(dataPoints)
        pointDots.enter().append('circle').attr('class','pointDots')
        .attr('r', 3)
        .attr('cx', (d) -> xScale(d[0]))
        .attr('cy', (d) -> yScale(d[1]))
        .attr('fill', (d) -> if d[2]? then color(d[2]) else 'black')

        pointDots.transition().duration(100)
        .attr('cx', (d) -> xScale(d[0]))
        .attr('cy', (d) -> yScale(d[1]))
        .attr('fill', (d) -> if d[2]? then color(d[2]) else 'black')
        pointDots.exit().remove()
