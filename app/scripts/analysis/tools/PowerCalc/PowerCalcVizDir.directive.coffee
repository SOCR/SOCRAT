'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class PowerCalcVizDiv extends BaseDirective
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
          drawNormalCurve(newChartData)
      , on

      scope.$watch 'mainArea.barChartData', (newChartData) =>
        if newChartData
          drawBarGraph(newChartData)
      , on

      drawBarGraph = (newChartData) ->

        # setting up frame
        proportion = newChartData
        padding = 50
        width = 500 - MARGIN.left - MARGIN.right
        height = 500 - MARGIN.top - MARGIN.bottom
        container = d3.select(elem[0])
        container.select('svg').remove()
        svg = container.append('svg')
          .attr('width', width + MARGIN.left + MARGIN.right)
          .attr('height', height + MARGIN.top + MARGIN.bottom)
        _graph = svg.append('g')
          .attr('transform', 'translate(' + MARGIN.left + ',' + MARGIN.top + ')')

        # draw axises
        x = d3.scale.linear().range([ padding, width - padding ])
        y = d3.scale.linear().range([ height - padding, padding ])
        y.domain([0,1])
        xAxis = d3.svg.axis().scale(x).orient('bottom')
          .tickFormat("")
        yAxis = d3.svg.axis().scale(y).orient('left')
        #x-axis
        _graph.append('g')
          .attr('class', 'x axis')
          .attr('transform', 'translate(0,' + (width - padding) + ')')
          .call xAxis
        #y-axis
        _graph.append('g')
          .attr('class', 'y axis')
          .attr('transform', 'translate(' + padding + ',0)' )
          .call yAxis
          .style('font-size', '16px')
        #adjust width
        _graph.selectAll('.x.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
        _graph.selectAll('.y.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})

        # create bar elements
        colorContainer = d3.scale.category10()
        barWidth = 0.15*(width-padding)
        svg.selectAll("rect")
         .data(proportion)
         .enter()
         .append("rect")
         .attr("x", (d,i) -> 130 + i * 90 )
         .attr("y", (d) -> 430 - 430*(d*0.835))
         .attr("width", barWidth)
         .attr("height", (d) -> 430*(d*0.835))
         .attr('fill', (d,i) -> colorContainer(i))
         .style('opacity', 0.75)
        
        labX = 40
        for lab in scope.mainArea.compAgents
          svg.append("text")
           .attr("class", "label")
           .attr("y", 450)
           .attr("x", labX += 90)
           .text(lab)

      drawNormalCurve = (newChartData) ->

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
        yScale = d3.scale.linear().range([height-padding, 0]).domain([bounds.bottom + 0.0001, bounds.top])

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

        color = d3.scale.category10()

        for datum, i in data
          _graph.append('svg:path')
            .attr('d', lineGen(datum))
            .data([datum])
            .attr('stroke', 'black')
            .attr('stroke-width', 1)
            .attr('fill', color(i))
            .style('opacity', 0.75)

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
        return
