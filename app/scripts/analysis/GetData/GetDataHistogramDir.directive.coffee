'use strict'

require 'jquery-ui/ui/widgets/slider'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class GetDataHistogramDir extends BaseDirective

  initialize: ->
    @restrict = 'E'
    @template = "<div class='graph-container' style='height:50px;width:50px'></div>"

    @link = (scope, elem, attr) =>
      console.log "UPDATING CHARTS"  
      margin = {top: 5, right: 5, bottom: 5, left:5}
      width = 160 - margin.left - margin.right
      height = 70 - margin.top - margin.bottom
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
          xScale = d3.scale.linear().range([
            0
            width
          ]).domain([
            0
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
          svg.selectAll('rect').data(histogramData).enter().append('rect').attr('width', (d) ->
            xScale(d.dx) - 2
          ).attr('height', (d) ->
            yScale d.y
          ).attr('x', (d) ->
            xScale(d.x) + 2
          ).attr 'y', (d) ->
            height - yScale(d.y)
