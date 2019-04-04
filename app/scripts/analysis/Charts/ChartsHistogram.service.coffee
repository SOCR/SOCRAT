'use strict'

require 'vega-tooltip'
BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsHistogram extends BaseService
  @inject '$q',
    '$stateParams',
    'app_analysis_charts_dataTransform',
    'app_analysis_charts_list',
    'app_analysis_charts_sendData',
    'app_analysis_charts_checkTime',
    'app_analysis_charts_dataService',
    'app_analysis_charts_msgService'

  initialize: ->
    @msgService = @app_analysis_charts_msgService
    @dataService = @app_analysis_charts_dataService
    @dataTransform = @app_analysis_charts_dataTransform
    @list = @app_analysis_charts_list
    @sendData = @app_analysis_charts_sendData
    @checkTime = @app_analysis_charts_checkTime
    @DATA_TYPES = @dataService.getDataTypes()

    @ve = require 'vega-embed'
    @vt = require 'vega-tooltip'

  plotHist: (bins, data, labels, flags) ->

    x_ = labels.xLab.value
    y_ = labels.yLab.value

    sumx = 0
    sumy = 0
    for dic in data
      sumx += parseFloat(dic[x_])
      sumy += parseFloat(dic[y_])

    mean_x = sumx/data.length
    mean_y = sumy/data.length

    for dic in data
      dic["residual_x"] = dic[x_] - mean_x
      dic["residual_y"] = dic[y_] - mean_y

    if (flags.x_residual)
      labels.xLab.value = "residual_x"

    if (flags.y_residual)
      labels.yLab.value = "residual_y"

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "width": 500,
      "height": 500,
      "data": {"values": data},
      "layer": [{
        "mark": "bar",
        "encoding": {
          "x": {
            "bin": {"maxbins": bins},
            "field": labels.xLab.value,
            "type": "quantitative",
            "axis": {"title": labels.xLab.value}
          }
        }
      }, {
        "mark": "rule",
        "encoding": {
          "x": {
            "aggregate": "mean",
            "field": labels.xLab.value,
            "type": "quantitative"
          },
          "color": {"value": "red"},
          "size": {"value": 5}
        }
      }]
    }

    if labels.yLab.value is "Count"
      vlSpec["layer"][0]["encoding"]["y"] = {"aggregate": "count", "field": labels.xLab.value,"type": "quantitative", "title": "Count"}
    else
      vlSpec["layer"][0]["encoding"]["y"] = {"field": labels.yLab.value,"type": "quantitative", "axis": {"title": labels.yLab.value}}

    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )

  drawHist: (data, labels, container, flags) ->
#    to find the min and max of a certain key in a list of objects
#    [
#      {x: 1, y: 4},
#      {x: 2, y: 3},
#      {x: 3, y: 1},
#      {x: 4, y: 2}
#    ]
#    min = Math.min.apply Math, data.map((o) -> o[labels.xLab.value])
#    max = Math.max.apply Math, data.map((o) -> o[labels.xLab.value])

    bins = 5
    @plotHist(bins, data,labels, flags)

    container.select("#slider").remove()
    container.append('div').attr('id', 'slider')
    container.select("#maxbins").remove()
    container.append('div').attr('id', 'maxbins').text('Max bins: 5')

    $slider = $("#slider")

    if $slider.length > 0
      $slider.slider(
        min: 1
        max: 10
        value: 5
        orientation: "horizontal"
        range: "min"
        change: ->
      ).addSliderSegments($slider.slider("option").max)

    $slider.on "slide", (event, ui) =>
      bins = parseInt ui.value
      d3.select('div#maxbins').text('Max bins: ' + bins)
      @plotHist(bins, data,labels)
