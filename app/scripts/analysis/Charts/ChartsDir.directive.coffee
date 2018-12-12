'use strict'

require 'jquery-ui/ui/widgets/slider'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class ChartsDir extends BaseDirective
  @inject 'app_analysis_charts_areaChart',
          'app_analysis_charts_areaTrellisChart'
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
          'app_analysis_charts_tukeyBoxPlot',
          'app_analysis_charts_checkTime',
          'app_analysis_charts_binnedHeatmap',
          'app_analysis_charts_stripPlot'
          'app_analysis_charts_scatterMatrix'
          'app_analysis_charts_divergingStackedBar'
          'app_analysis_charts_rangedDotPlot'
          'app_analysis_charts_bulletChart'
          'app_analysis_charts_wordCloud'
          'app_analysis_charts_sunburst'
          'app_analysis_charts_cumulative'
          'app_analysis_charts_residual'

  initialize: ->
    @areaTrellis = @app_analysis_charts_areaTrellisChart
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
    @tukeyBoxPlot = @app_analysis_charts_tukeyBoxPlot
    @binnedHeatmap = @app_analysis_charts_binnedHeatmap
    @stripPlot = @app_analysis_charts_stripPlot
    @scatterMatrix = @app_analysis_charts_scatterMatrix
    @divergingStackedBar = @app_analysis_charts_divergingStackedBar
    @rangedDotPlot = @app_analysis_charts_rangedDotPlot
    @bulletChart = @app_analysis_charts_bulletChart
    @wordCloud = @app_analysis_charts_wordCloud
    @sunburst = @app_analysis_charts_sunburst
    @cumulativeFrequency = @app_analysis_charts_cumulative
    @residual = @app_analysis_charts_residual
    @mapChart = @app_analysis_charts_mapChart
    #@charts = [@areaTrellis, @bar, @bubble, @histogram, @pie, @scatterPlot, @stackBar, @time,
      #@trellis, @streamGraph, @area, @treemap, @line, @bivariate, @normal, @tukeyBoxPlot, @binnedHeatmap, @stripPlot]
    @charts = [@scatterPlot, @bar, @binnedHeatmap, @bubble, @histogram, @pie,
      @normal, @tukeyBoxPlot, @stripPlot, @scatterMatrix, @rangedDotPlot, @wordCloud]

    @restrict = 'E'
    @template = "<div id='vis' class='graph-container' style='overflow:auto; height: 600px'></div>"

    @link = (scope, elem) =>
      data = null
      labels = null
      container = null

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
          if newChartData and newChartData.chartParams
            data = newChartData.chartParams.data
            labels = newChartData.chartParams.labels
            scheme = newChartData.chartParams.graph
            flags = newChartData.chartParams.flags

          d3charts = d3.select(elem.find('div')[0]).node().parentNode
          container = d3.select(d3charts)

          switch scheme.name
            when 'Trellis Chart'
              @trellis.drawTrellis(data, labels, container)
            when 'Area Trellis Chart'
              @areaTrellis.areaTrellisChart(data,ranges,width,height,_graph,labels,container)
            when 'Binned Heatmap'
              @binnedHeatmap.drawHeatmap(data, labels, container, flags)
            when 'Bar Graph'
              @bar.drawBar(data, labels, container, flags)
            when 'Bubble Chart'
              @bubble.drawBubble(data, labels, container)
            when 'Histogram'
              @histogram.drawHist(data, labels, container, flags)
            when 'Tukey Box Plot (1.5 IQR)'
              @tukeyBoxPlot.drawBoxPlot(data, labels, container, flags)
            when 'Scatter Plot'
              @scatterPlot.drawScatterPlot(data, labels, container, flags)
            when 'Stacked Bar Chart'
              @stackBar.stackedBar(data, labels, container)
            when 'Stream Graph'
              @streamGraph.streamGraph(data, labels, container)
            when 'Strip Plot'
              @stripPlot.drawStripPlot(data, labels, container)
            when 'Area Chart'
              @area.drawArea(data, labels, container)
            when 'Treemap'
              @treemap.drawTreemap(data, labels, container)
            when 'Line Chart'
              @line.lineChart(data, labels, container)
            when 'Bivariate Area Chart'
              # @time.checkTimeChoice(data)
              @bivariate.bivariateChart(height,width,_graph, data, labels)
            when 'Normal Distribution'
              @normal.drawNormalCurve(data, labels, container, flags)
            when 'Pie Chart'
              @pie.drawPie(data, labels, container, flags)
            when 'Scatter Plot Matrix'
              @scatterMatrix.drawScatterMatrix(data, labels, container)
            when 'Diverging Stacked Bar Chart'
              @divergingStackedBar.drawDivergingStackedBar(data, labels, container)
            when 'Ranged Dot Plot'
              @rangedDotPlot.drawRangedDotPlot(data, labels, container, flags)
            when 'Bullet Chart'
              @bulletChart.drawBulletChart(data, labels, container)
            when 'Word Cloud'
              @wordCloud.drawWordCloud(data, labels, container, flags)
            when 'Sunburst'
              @sunburst.drawSunburst(data, labels, container)
            when 'Cumulative Frequency'
              @cumulativeFrequency.drawCumulativeFrequency(data, labels, container, flags)
            when 'Residuals'
              @residual.drawResidual(data, labels, container)

