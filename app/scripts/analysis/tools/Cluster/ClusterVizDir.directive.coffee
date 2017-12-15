'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class ClusterVizDir extends BaseDirective
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
      meanLayer = null

      svg = d3.select(elem[0])
      graph = svg.append('g').attr('transform', 'translate(' +  MARGIN_LEFT + ',' + MARGIN_TOP + ')')
      meanLayer = graph.append('g')
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
          yScale = d3.scale.linear().domain([minYDataPoint, maxYDataPoint]).range([500, 0])
          drawDataPoints newDataPoints
      , on

      scope.$watchCollection 'mainArea.assignments', (newAssignments) =>
        if newAssignments
          redraw scope.mainArea.dataPoints, scope.mainArea.means, newAssignments
        else reset()

      drawDataPoints = (dataPoints) ->
        meanLayer.selectAll('.meanDots').remove()
        meanLayer.selectAll('.assignmentLines').remove()

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

        MARGIN =
          top: 20
          right: 20
          bottom: 20
          left:20

        width = 500 - MARGIN.left - MARGIN.right
        height = 500 - MARGIN.top - MARGIN.bottom

        xAxis = d3.svg.axis().ticks(10)
        .orient("bottom")
        .scale(xScale)

        console.log(yScale)

        yAxis = d3.svg.axis()
        .scale(yScale)
        .ticks(10)
        .tickPadding(0)
        .orient('left')

        lineGen = d3.svg.line()
        .x (d) -> xScale(d.x)
        .y (d) -> yScale(d.y)
        .interpolate('basis')

        color = d3.scale.category10()

        padding_top = 500
        padding = 0

        # x-axis
        graph.append('svg:g')
        .attr('class', 'x axis')
        .attr("transform", "translate(0," + padding_top + ")")
        .call(xAxis)

        # y-axis
        graph.append('svg:g')
        .attr('class', 'y axis')
        .attr("transform", "translate("+padding+",0)")
        .call(yAxis)

        # make x y axis thin
        graph.selectAll('.x.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
        graph.selectAll('.y.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})


      reset = () ->
        meanLayer.selectAll('.meanDots').remove()
        meanLayer.selectAll('.assignmentLines').remove()

      redraw = (dataPoints, means, assignments) ->
        assignmentLines = meanLayer.selectAll('.assignmentLines').data(assignments)
        assignmentLines.enter().append('line').attr('class','assignmentLines')
        .attr('x1', (d, i) -> xScale(dataPoints[i][0]))
        .attr('y1', (d, i) -> yScale(dataPoints[i][1]))
        .attr('x2', (d, i) -> xScale(means[d][0]))
        .attr('y2', (d, i) -> yScale(means[d][1]))
        .attr('stroke', (d) -> color(d))

        assignmentLines.transition().duration(500)
        .attr('x2', (d, i) -> xScale(means[d][0]))
        .attr('y2', (d, i) -> yScale(means[d][1]))
        .attr('stroke', (d) -> color(d))

        meanDots = meanLayer.selectAll('.meanDots').data(means)
        meanDots.enter().append('circle').attr('class','meanDots')
        .attr('r', 5)
        .attr('stroke', (d, i) -> color(i))
        .attr('stroke-width', 3)
        .attr('fill', 'white')
        .attr('cx', (d) -> xScale(d[0]))
        .attr('cy', (d) -> yScale(d[1]))

        meanDots.transition().duration(500)
        .attr('cx', (d) -> xScale(d[0]))
        .attr('cy', (d) -> yScale(d[1]))
        meanDots.exit().remove()
