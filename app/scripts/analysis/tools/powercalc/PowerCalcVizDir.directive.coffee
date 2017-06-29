'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class PowercalcVizDiv extends BaseDirective
  @inject '$parse'

  initialize: ->
    @restrict = 'E'
    @template = "<div id='#twoTestGraph' class='graph'></div>"
    @replace = true # replace the directive element with the output of the template

    # The link method does the work of setting the directive
    #  up, things like bindings, jquery calls, etc are done in here
    @link = (scope, elem, attr) =>

      MARGIN =
        top: 20
        right: 20
        bottom: 20
        left:20

      scope.$watch 'mainArea.chartData', (newChartData) =>
        if newChartData
          if scope.mainArea.selectedAlgorithm is "Two-sample t test (general case)"
            twoTestDrawNormalCurve(newChartData)
      , on

      twoTestDrawNormalCurve = (newChartData) ->

        bounds = newChartData.bounds
        data = newChartData.data

        width = 500 - MARGIN.left - MARGIN.right
        height = 500 - MARGIN.top - MARGIN.bottom

        container = d3.select(elem[0])
        container.select('svg').remove()

        svg = container.append('svg')
          .attr('width', width + MARGIN.left + MARGIN.right)
          .attr('height', height + MARGIN.top + MARGIN.bottom)

        _graph = svg.append('g')
          .attr('transform', 'translate(' + MARGIN.left + ',' + MARGIN.top + ')')

        radiusCoef = 5

        padding = 50
        xScale = d3.scale.linear().range([0, width]).domain([bounds.left, bounds.right])
        #console.log 'xScale: ' + xScale
        yScale = d3.scale.linear().range([height-padding, 0]).domain([bounds.bottom, bounds.top])

        xAxis = d3.svg.axis().ticks(10)
        .scale(xScale)

        yAxis = d3.svg.axis()
        .scale(yScale)
        .ticks(10)
        .tickPadding(0)
        .orient('right')

        lineGen = d3.svg.line()
        .x (d) -> xScale(d.x)
        .y (d) -> yScale(d.y)
        .interpolate('basis')

        # for datum in data
        #   _graph.append('svg:path')
        #     .attr('d', lineGen(datum))
        #     .data([datum])
        #     .attr('stroke', 'black')
        #     .attr('stroke-width', 5)
        #     .attr('fill', 'blue')
        #     .style('opacity', 0.5)

        # data1
        path1 = _graph.append('svg:path')
        .attr('d', lineGen(data[0]))
        .data([data[0]])
        .attr('stroke', 'black')
        .attr('stroke-width', 5)
        .attr('fill', 'blue')
        .style('opacity', 0.5)

        # data2
        path2 = _graph.append('svg:path')
        .attr('d', lineGen(data[1]))
        .data([data[1]])
        .attr('stroke', 'red')
        .attr('stroke-width', 5)
        .attr('fill', 'chocolate')
        .style('opacity', 0.5)

        # x-axis
        _graph.append('svg:g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(0,' + (height - padding) + ')')
        .call(xAxis)

        # y-axis
        _graph.append('svg:g')
        .attr('class', 'y axis')
        .attr('transform', 'translate(' + (xScale(bounds.left))+ ',0)')
        .call(yAxis)

        # make x y axis thin
        _graph.selectAll('.x.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
        _graph.selectAll('.y.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})

        # display lengend1
        svg.append('text')
        .attr('id', 'displayLegend1')
        .attr('x', xScale(bounds.right * 0.9))
        .attr('y', yScale(bounds.top * 0.9))
        .style('text-anchor', 'middle')
        .attr('fill', 'blue');

        # display legend2
        svg.append('text')
        .attr('id', 'displayLegend2')
        .attr('x', xScale(bounds.right * 0.9))
        .attr('y', yScale(bounds.top * 0.85))
        .style('text-anchor', 'middle')
        .attr('fill', 'chocolate');

        # rotate text on x axis
        # _graph.selectAll('.x.axis text')
        # .attr('transform', (d) ->
        #    'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
        # .style('font-size', '16px')
        if scope.mainArea.deployed
          $("#displayLegend1").text(scope.mainArea.comp_agents[0]+": "+scope.mainArea.twoTestmean1.toFixed(3))
          $("#displayLegend2").text(scope.mainArea.comp_agents[1]+": "+scope.mainArea.twoTestmean2.toFixed(3))
          $("#displayLegend1").css("background-color","aquamarine")
          $("#displayLegend2").css("background-color","chocolate")
        else
          $("#displayLegend1").text("Sample1: " + scope.mainArea.twoTestmean1.toFixed(3))
          $("#displayLegend2").text("Sample2: " + scope.mainArea.twoTestmean2.toFixed(3))
          $("#displayLegend1").css("background-color","aquamarine")
          $("#displayLegend2").css("background-color","chocolate")


        return
