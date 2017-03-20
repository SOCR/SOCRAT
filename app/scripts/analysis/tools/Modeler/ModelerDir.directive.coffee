'use strict'

require 'jquery-ui/ui/widgets/slider'


BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class ModelerDir extends BaseDirective
  @inject 'socrat_analysis_modeler_hist',
    'socrat_analysis_modeler_getParams'

  initialize: ->
    console.log("initalizing modeler dir")
    #@normal = @socrat_modeler_distribution_normal
    @histogram = @socrat_analysis_modeler_hist
    @getParams = @socrat_analysis_modeler_getParams
    @restrict = 'E'
    @template = "<div class='graph-container' style='height: 600px'></div>"
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
        console.log("New data points recognized:" )
        console.log(newChartData)
        if newChartData
          gdata = newChartData.labels
          data = newChartData.dataPoints
          scheme = newChartData.distribution

          data = data.map (row) ->
            x: row[0]
            y: row[1]
            z: row[2]


          container = d3.select(elem.find('div')[0])
          container.selectAll('*').remove()

          svg = container.append('svg')
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          svg.select("#remove").remove()

          _graph = svg.append('g')
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

          ranges =
            xMin: if gdata.xLab.type in numerics then d3.min(data, (d) -> parseFloat(d.x)) else null
            yMin: if gdata.yLab.type in numerics then d3.min(data, (d) -> parseFloat(d.y)) else null
            zMin: if gdata.zLab.type in numerics then d3.min(data, (d) -> parseFloat(d.z)) else null

            xMax: if gdata.xLab.type in numerics then d3.max(data, (d) -> parseFloat(d.x)) else null
            yMax: if gdata.yLab.type in numerics then d3.max(data, (d) -> parseFloat(d.y)) else null
            zMax: if gdata.zLab.type in numerics then d3.max(data, (d) -> parseFloat(d.z)) else null


          console.log("Mean")
          console.log("Printing Histogram")


          @histogram.drawHist(_graph,data,container,gdata,width,height,ranges)
          switch scheme.name
            when 'Histogram'
              @histogram.drawHist(_graph,data,container,gdata,width,height,ranges)





