'use strict'

require 'jquery-ui/ui/widgets/slider'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class GetDataHistogramDir extends BaseDirective

  initialize: ->
    @restrict = 'E'
    @template = "<div class='graph-container'></div>"

    @link = (scope, elem, attr) =>

      margin = {top: 5, right: 5, bottom: 5, left:5}
      width = 100 - margin.left - margin.right
      height = 60 - margin.top - margin.bottom
      colName = attr.colName
          
      scope.$watch 'mainArea.colHistograms', (newChartData) =>
        if newChartData
          data = newChartData[colName]
          container = d3.select(elem.find('div')[0])
          container.selectAll('*').remove()

          # http://codepen.io/swizec/pen/JRzWwj?editors=1010
          histogram = d3.layout.histogram().bins(10)
          histogramData = histogram(data)
          svg = container.append('svg')
          .attr('width',width + margin.left +
           margin.right)
          .attr('height',height + margin.top + margin.bottom)

          xScale = d3.scale.linear().range([
            0
            width
          ]).domain([
            d3.min(data)
            d3.max(histogramData, (d) ->
              d.x + d.dx
            )
          ])
          
          yScale = d3.scale.linear().range([
            0
            height
          ]).domain([
            0
            d3.max(histogramData, (d) ->
              d.y
            )
          ])
          svg.selectAll('rect').data(histogramData).enter().append('rect')
          .attr('fill','steelblue')
          .attr('width', (d) ->  
            # console.log(d.dx,xScale(d.dx),xScale.domain(), xScale.range())
            xScale(xScale.domain()[0]+d.dx) - 2
          ).attr('height', (d) ->
            yScale d.y
          ).attr('x', (d) ->
            xScale(d.x) + 2
          ).attr 'y', (d) ->
            height - yScale(d.y)
