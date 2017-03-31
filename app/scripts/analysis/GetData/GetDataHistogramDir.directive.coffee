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
      
      histogramChart = ->
        histogram = d3.layout.histogram()
        x = d3.scale.ordinal()
        y = d3.scale.linear()
        xAxis = d3.svg.axis().scale(x).orient('bottom').tickSize(6, 0)

        chart = (selection) ->
          selection.each (data) ->
            # Compute the histogram.
            data = histogram(data)
            # Update the x-scale.
            x.domain(data.map((d) ->
              d.x
            )).rangeRoundBands [
              0
              width - (margin.left) - (margin.right)
            ], 0.1
            # Update the y-scale.
            y.domain([
              0
              d3.max(data, (d) ->
                d.y
              )
            ]).range [
              height - (margin.top) - (margin.bottom)
              0
            ]
            # Select the svg element, if it exists.
            svg = d3.select(this).selectAll('svg').data([ data ])
            # Otherwise, create the skeletal chart.
            gEnter = svg.enter().append('svg').append('g')
            gEnter.append('g').attr 'class', 'bars'
            gEnter.append('g').attr 'class', 'x axis'
            # Update the outer dimensions.
            svg.attr('width', width).attr 'height', height
            # Update the inner dimensions.
            g = svg.select('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
            # Update the bars.
            bar = svg.select('.bars').selectAll('.bar').data(data)
            bar.enter().append 'rect'
            bar.exit().remove()
            bar.attr('width', x.rangeBand()).attr('x', (d) ->
              x d.x
            ).attr('y', (d) ->
              y d.y
            ).attr('height', (d) ->
              y.range()[0] - y(d.y)
            ).order()
            # Update the x-axis.
            g.select('.x.axis').attr('transform', 'translate(0,' + y.range()[0] + ')').call xAxis
            return
          return

        chart.margin = (_) ->
          if !arguments.length
            return margin
          margin = _
          chart

        chart.width = (_) ->
          if !arguments.length
            return width
          width = _
          chart

        chart.height = (_) ->
          if !arguments.length
            return height
          height = _
          chart

        # Expose the histogram's value, range and bins method.
        d3.rebind chart, histogram, 'value', 'range', 'bins'
        # Expose the x-axis' tickFormat method.
        d3.rebind chart, xAxis, 'tickFormat'
        chart
      
      irwinHallDistribution = (n, m) ->
        distribution = []
        i = 0
        while i < n
          s = 0
          j = 0
          while j < m
            s += Math.random()
            j++
          distribution.push s / m
          i++
        distribution

      scope.$watch 'mainArea.colHistograms', (newChartData) =>
        if newChartData
          data = newChartData[colName]
          container = d3.select(elem.find('div')[0])
          container.selectAll('*').remove()
          if colName > 2
            container.datum(data).call histogramChart().bins(d3.scale.linear().ticks(10)).tickFormat(d3.format('.02f'))
          else
            container.datum(irwinHallDistribution(10000, 10)).call histogramChart().bins(d3.scale.linear().ticks(20)).tickFormat(d3.format('.02f'))
