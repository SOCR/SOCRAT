'use strict'

require 'jquery-ui/ui/widgets/slider'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class ChartsDir extends BaseDirective
  @inject 'app_analysis_charts_areaChart',
          'app_analysis_charts_barChart',
          'app_analysis_charts_bivariateLineChart',
          'app_analysis_charts_bubbleChart',
          'app_analysis_charts_histogram',
          'app_analysis_charts_lineChart',
          'app_analysis_charts_normalChart',
          'app_analysis_charts_pieChart',
          'app_analysis_charts_scatterPlot',
          'app_analysis_charts_streamChart',
          'app_analysis_charts_stackedBar',
          'app_analysis_charts_tilfordTree',
          'app_analysis_charts_trellisChart',
          'app_analysis_charts_treemap',
          'app_analysis_charts_checkTime'

  initialize: ->
    @bar = @app_analysis_charts_barChart
    @bubble = @app_analysis_charts_bubbleChart
    @histogram = @app_analysis_charts_histogram
    @pie = @app_analysis_charts_pieChart
    @scatterPlot = @app_analysis_charts_scatterPlot
    @stackBar = @app_analysis_charts_stackedBar
    @time = @app_analysis_charts_checkTime
    @trellis = @app_analysis_charts_trellisChart
    @streamGraph = @app_analysis_charts_streamChart
    @area = @app_analysis_charts_areaChart
    @treemap = @app_analysis_charts_treemap
    @line = @app_analysis_charts_lineChart
    @bivariate = @app_analysis_charts_bivariateLineChart
    @normal = @app_analysis_charts_normalChart
    @pie = @app_analysis_charts_pieChart

    @restrict = 'E'
    @template = "<div id='vis' class='graph-container' style='overflow:auto; height: 600px'></div>"

    @link = (scope, elem, attr) =>
      margin = {top: 10, right: 40, bottom: 50, left:80}
      width = 750 - margin.left - margin.right
      height = 500 - margin.top - margin.bottom
      svg = null
      data = null
      _graph = null
      container = null
      labels = null
      ranges = null

      numerics = ['integer', 'number']

      # add segments to a slider
      # https://designmodo.github.io/Flat-UI/docs/components.html#fui-slider
      $.fn.addSliderSegments = (amount, orientation) ->
        @.each () ->
          if orientation is "vertical"
            output = ''
            for i in [0..amount-2]
              output += '<div class="ui-slider-segment" style="top:' + 100 / (amount - 1) * i + '%;"></div>'
            $(this).prepend(output)
          else
            segmentGap = 100 / (amount - 1) + "%"
            segment = '<div class="ui-slider-segment" style="margin-left: ' + segmentGap + ';"></div>'
            $(this).prepend(segment.repeat(amount - 2))

      scope.$watch 'mainArea.chartData', (newChartData) =>

        if newChartData and newChartData.dataPoints
          data = newChartData.dataPoints
          labels = newChartData.labels
          scheme = newChartData.graph

          container = d3.select(elem.find('div')[0])
          container.selectAll('*').remove()

          svg = container.append('svg')
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
          #svg.select("#remove").remove()

          _graph = svg.append('g')
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

          # trellis chart is called differently
          if scheme.name is 'Trellis Chart' and newChartData.labels
            @trellis.drawTrellis(width, height, data, _graph, labels, container)
          # standard charts
          else
            data = data.map (row) ->
              x: row[0]
              y: row[1]
              z: row[2]
              r: row[3]

            ranges =
              xMin: if labels? and numerics.includes(labels.xLab.type) then d3.min(data, (d) -> parseFloat(d.x)) else null
              yMin: if labels? and numerics.includes(labels.yLab.type) then d3.min(data, (d) -> parseFloat(d.y)) else null
              zMin: if labels? and numerics.includes(labels.zLab.type) then d3.min(data, (d) -> parseFloat(d.z)) else null

              xMax: if labels? and numerics.includes(labels.xLab.type) then d3.max(data, (d) -> parseFloat(d.x)) else null
              yMax: if labels? and numerics.includes(labels.yLab.type) then d3.max(data, (d) -> parseFloat(d.y)) else null
              zMax: if labels? and numerics.includes(labels.zLab.type) then d3.max(data, (d) -> parseFloat(d.z)) else null

            switch scheme.name
              when 'Bar Graph'
                @bar.drawBar(width,height,data,_graph,labels,ranges)
              when 'Bubble Chart'
                @bubble.drawBubble(width,height,_graph,data,labels,container,ranges)
              when 'Histogram'
                @histogram.drawHist(_graph,data,container,labels,width,height,ranges)
              when 'Ring Chart'
                _graph = svg.append('g').attr("transform", "translate(300,250)").attr("id", "remove")
                @pie.drawPie(data,width,height,_graph,false)
              when 'Scatter Plot'
                @scatterPlot.drawScatterPlot(data,ranges,width,height,_graph,container,labels)
              when 'Stacked Bar Chart'
                @stackBar.stackedBar(data,ranges,width,height,_graph, labels,container)
              when 'Stream Graph'
                @time.checkTimeChoice(data)
                @streamGraph.streamGraph(data,ranges,width,height,_graph, scheme)
              when 'Area Chart'
                @time.checkTimeChoice(data)
                @area.drawArea(height,width,_graph, data, labels)
              when 'Treemap'
                @treemap.drawTreemap(svg, width, height, container, data)
              when 'Line Chart'
                @time.checkTimeChoice(data)
                @line.lineChart(data,ranges,width,height,_graph, labels,container)
              when 'Bivariate Area Chart'
                @time.checkTimeChoice(data)
                @bivariate.bivariateChart(height,width,_graph, data, labels)
              when 'Normal Distribution'
                @normal.drawNormalCurve(data, width, height, _graph)
              when 'Pie Chart'
                _graph = svg.append('g').attr("transform", "translate(300,250)").attr("id", "remove")
                @pie.drawPie(data,width,height,_graph,true)
