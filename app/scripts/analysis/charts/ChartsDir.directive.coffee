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
    @streamGraph = @app_analysis_charts_streamChart
    @area = @app_analysis_charts_areaChart
    @treemap = @app_analysis_charts_treemap
    @line = @app_analysis_charts_lineChart
    @bivariate = @app_analysis_charts_bivariateLineChart
    @normal = @app_analysis_charts_normalChart
    @pie = @app_analysis_charts_pieChart

    @restrict = 'E'
    @template = "<div class='graph-container' style='height: 600px'></div>"
    console.log("in dir")
    @link = (scope, elem, attr) =>
      margin = {top: 10, right: 40, bottom: 50, left:80}
      width = 750 - margin.left - margin.right
      height = 500 - margin.top - margin.bottom
      svg = null
      data = null
      _graph = null
      container = null
      gdata = null
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
        console.log("New chart  points recognized:" )
        console.log(newChartData)
        if newChartData
          gdata = newChartData.labels
          data = newChartData.dataPoints
          scheme = newChartData.graph
          console.log("chart data " + data)
          data = data.map (row) ->
            x: row[0]
            y: row[1]
            z: row[2]


          container = d3.select(elem.find('div')[0])
          container.selectAll('*').remove()

          svg = container.append('svg')
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
          #svg.select("#remove").remove()

          _graph = svg.append('g')
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

          ranges =
            xMin: if gdata.xLab.type in numerics then d3.min(data, (d) -> parseFloat(d.x)) else null
            yMin: if gdata.yLab.type in numerics then d3.min(data, (d) -> parseFloat(d.y)) else null
            zMin: if gdata.zLab.type in numerics then d3.min(data, (d) -> parseFloat(d.z)) else null

            xMax: if gdata.xLab.type in numerics then d3.max(data, (d) -> parseFloat(d.x)) else null
            yMax: if gdata.yLab.type in numerics then d3.max(data, (d) -> parseFloat(d.y)) else null
            zMax: if gdata.zLab.type in numerics then d3.max(data, (d) -> parseFloat(d.z)) else null

          switch scheme.name
            when 'Bar Graph'
              @bar.drawBar(width,height,data,_graph,gdata)
            when 'Bubble Chart'
              @bubble.drawBubble(ranges,width,height,_graph,data,gdata,container)
            when 'Histogram'
              @histogram.drawHist(_graph,data,container,gdata,width,height,ranges)
            when 'Ring Chart'
              _graph = svg.append('g').attr("transform", "translate(300,250)").attr("id", "remove")
              @pie.drawPie(data,width,height,_graph,false)
            when 'Scatter Plot'
              @scatterPlot.drawScatterPlot(data,ranges,width,height,_graph,container,gdata)
            when 'Stacked Bar Chart'
              @stackBar.stackedBar(data,ranges,width,height,_graph, gdata,container)
            when 'Stream Graph'
              @time.checkTimeChoice(data)
              @streamGraph.streamGraph(data,ranges,width,height,_graph, scheme)
            when 'Area Chart'
              @time.checkTimeChoice(data)
              @area.drawArea(height,width,_graph, data, gdata)
            when 'Treemap'
              @treemap.drawTreemap(svg, width, height, container, data)
            when 'Line Chart'
              @time.checkTimeChoice(data)
              @line.lineChart(data,ranges,width,height,_graph, gdata,container)
            when 'Bivariate Area Chart'
              @time.checkTimeChoice(data)
              @bivariate.bivariateChart(height,width,_graph, data, gdata)
            when 'Normal Distribution'
              @normal.drawNormalCurve(data, width, height, _graph)
            when 'Pie Chart'
              _graph = svg.append('g').attr("transform", "translate(300,250)").attr("id", "remove")
              @pie.drawPie(data,width,height,_graph,true)
