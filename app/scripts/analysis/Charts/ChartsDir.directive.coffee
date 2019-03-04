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
<<<<<<< HEAD
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
=======
          'app_analysis_charts_parallelCoordinates'
>>>>>>> 855ec727268ceb15b1101fc091df509a095a4b9c

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
<<<<<<< HEAD
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
    #@charts = [@areaTrellis, @bar, @bubble, @histogram, @pie, @scatterPlot, @stackBar, @time,
      #@trellis, @streamGraph, @area, @treemap, @line, @bivariate, @normal, @tukeyBoxPlot, @binnedHeatmap, @stripPlot]
    @charts = [@scatterPlot, @bar, @binnedHeatmap, @bubble, @histogram, @pie,
      @normal, @tukeyBoxPlot, @stripPlot, @scatterMatrix, @rangedDotPlot, @wordCloud]
=======
    @parallelCoordinates = @app_analysis_charts_parallelCoordinates
>>>>>>> 855ec727268ceb15b1101fc091df509a095a4b9c

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
<<<<<<< HEAD
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
=======

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
          if scheme.name is 'Trellis Chart'
            @trellis.drawTrellis(width, height, data, _graph, labels, container)
          else if scheme.name is 'Parallel Coordinates Chart'
            @parallelCoordinates.drawParallel(data, width, height, _graph, labels)
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
              when 'Area Trellis Chart'
                @areaTrellis.areaTrellisChart(data,ranges,width,height,_graph,labels,container)
              when 'Bar Graph'
                @bar.drawBar(width,height,data,_graph,labels,ranges)
              when 'Bubble Chart'
                @bubble.drawBubble(width,height,_graph,data,labels,container,ranges)
              when 'Histogram'
                @histogram.drawHist(_graph, data, container, labels, width, height, ranges)
              when 'Tukey Box Plot (1.5 IQR)'
                @tukeyBoxPlot.drawBoxPlot(_graph, data, container, labels, width, height, ranges)
              when 'Ring Chart'
                _graph = svg.append('g').attr("transform", "translate(300,250)").attr("id", "remove")
                @pie.drawPie(data,width,height,_graph,false)
              when 'Scatter Plot'
                @scatterPlot.drawScatterPlot(data,ranges,width,height,_graph,container,labels)
              when 'Stacked Bar Chart'
                @stackBar.stackedBar(data,ranges,width,height,_graph, labels,container)
              when 'Stream Graph'
                @streamGraph.streamGraph(data,ranges,width,height,_graph,scheme,labels)
              when 'Area Chart'
                @area.drawArea(height,width,_graph, data, labels)
              when 'Treemap'
                @treemap.drawTreemap(svg, width, height, container, data)
              when 'Line Chart'
                @line.lineChart(data,ranges,width,height,_graph, labels,container)
              when 'Bivariate Area Chart'
                # @time.checkTimeChoice(data)
                @bivariate.bivariateChart(height,width,_graph, data, labels)
              when 'Normal Distribution'
                @normal.drawNormalCurve(data, width, height, _graph)
              when 'Pie Chart'
                _graph = svg.append('g').attr("transform", "translate(300,250)").attr("id", "remove")
                @pie.drawPie(data,width,height,_graph,true)
                
>>>>>>> 855ec727268ceb15b1101fc091df509a095a4b9c
