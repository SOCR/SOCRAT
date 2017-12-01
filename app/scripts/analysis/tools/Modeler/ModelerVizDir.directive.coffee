'use strict'

require 'jquery-ui/ui/widgets/slider'


BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class ModelerDir extends BaseDirective
  @inject 'socrat_analysis_modeler_hist',
    'socrat_analysis_modeler_getParams',
    'socrat_modeler_distribution_normal'

  initialize: ->

    console.log("initalizing modeler dir")
    @normal = @socrat_modeler_distribution_normal
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
          #if scheme.name is 'Trellis Chart' and newChartData.labels
          #  @trellis.drawTrellis(width, height, data, _graph, labels, container)
          # standard charts
          
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

          console.log("Mean")
          console.log("Printing Histogram")


          @histogram.drawHist(_graph,data,container,labels,width,height,ranges)
          
          #case for each distribution
          ###
          switch scheme.name
            when 'Histogram'
              @histogram.drawHist(_graph,data,container,gdata,width,height,ranges)
          ###






      scope.$watch 'mainArea.modelData', (modelData) =>
        console.log("Plotting Model Data");
        #console.log(data.dataPoints)
        #distribution = data.distribution
        ###
        data= modelData.dataPoints
        data = data.map (row) ->
            x: row[0]
            y: row[1]
            z: row[2]
            r: row[3]
        ###
        if modelData
          container = d3.select(elem[0])
          container.selectAll('path').remove()


          
          leftBound = modelData.stats.stats.leftBound
          rightBound = modelData.stats.stats.rightBound
          topBound = modelData.stats.stats.topBound
          bottomBound = modelData.stats.stats.bottomBound
          curveData = modelData
          
          padding = 50
          #xScale = d3.scale.linear().range([0, width]).domain([modelData.xMin, modelData.xMax])
          #yScale = d3.scale.linear().range([height-padding, 0]).domain([bottomBound, topBound])
         
          #************** Change for quantile scaling **************
          xScale = d3.scale.linear().range([padding, width - padding ]).domain([modelData.stats.xMin, modelData.stats.xMax])
          #changin scale for larger range
          #xScale = d3.scale.linear().range([padding, width - padding ]).domain([modelData.stats.leftBound, modelData.stats.rightBound])

          
          yScale = d3.scale.linear().range([height - padding, padding]).domain([bottomBound, topBound])

          #x.domain([d3.min(data, (d)->parseFloat d.x), d3.max(data, (d)->parseFloat d.x)])
          #y.domain([0, (d3.max dataHist.map (i) -> i.length)])
          xAxis = d3.svg.axis().ticks(20)
            .scale(xScale)

          yAxis = d3.svg.axis()
            .scale(yScale)
            .ticks(12)
            .tickPadding(0)
            .orient("right")

          lineGen = d3.svg.line()
            .x (d) -> xScale(d.x)
            .y (d) -> yScale(d.y)
            .interpolate("basis")

          console.log("printing gaussian curve data")
          #console.log(curveData)
          '''
          if modelData.distribution.name == 'Kernel'
            console.log("plotting for kernel")
            _graph.append('svg:path')
            .datum(curveData)
            .attr("class", "line")
            .attr('d', lineGen)
            .attr('stroke', 'black')
            .attr('stroke-width', 1.5)
            .attr('fill', "none")

          else 
          '''
          _graph.append('svg:path')
          .attr('d', lineGen(curveData))
          .data([curveData])
          .attr('stroke', 'black')
          .attr('stroke-width', 1.5)
          .on('mousemove', (d) -> showToolTip(getZ(xScale.invert(d3.event.x),mean,standardDerivation).toLocaleString(),d3.event.x,d3.event.y))
          .on('mouseout', (d) -> hideToolTip())
          .attr('fill', "none")



        '''
          if @distribution.name == 'Laplace'
              @container.append('div').attr('id', 'laplace_slider')
              $slider = $("#laplace_slider")
              if $slider.length > 0
              $slider.slider(
                min: 1
                max: 10
                value: 5
                orientation: "horizontal"
                range: "min"
                change: ->
              ).addSliderSegments($slider.slider("option").max)
              $slider.on "slidechange", (event, ui) =>
                b = parseInt ui.value
      #      tooltip.html()
                modelData = @
          '''


    

        
