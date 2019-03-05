'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsTukeyBoxPlot extends BaseService
  @inject '$q',
    '$stateParams',
    'app_analysis_charts_dataTransform',
    'app_analysis_charts_list',
    'app_analysis_charts_sendData',
    'app_analysis_charts_checkTime',
    'app_analysis_charts_dataService',
    'app_analysis_charts_msgService',
    'app_analysis_charts_scatterPlot'

  initialize: ->
    @msgService = @app_analysis_charts_msgService
    @dataService = @app_analysis_charts_dataService
    @dataTransform = @app_analysis_charts_dataTransform
    @list = @app_analysis_charts_list
    @sendData = @app_analysis_charts_sendData
    @checkTime = @app_analysis_charts_checkTime
    @DATA_TYPES = @dataService.getDataTypes()
    @scatterPlot = @app_analysis_charts_scatterPlot

    @ve = require 'vega-embed'
    @vt = require 'vega-tooltip'

  drawBoxPlot: (data, labels, container, flags) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    y_ = labels.yLab.value

    sumy = 0
    for dic in data
      sumy += parseFloat(dic[y_])

    mean_y = sumy/data.length

    for dic in data
      dic["residual_y"] = dic[y_] - mean_y

    if (flags.y_residual)
      labels.yLab.value = "residual_y"

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "width": 500,
      "height": 500,
      "data": {"values": data},
      "selection": {
        "brush": {
          "type": "interval",
          "encodings": ["x", "y"]
        }
      },
      "mark": {
        "type": "boxplot",
        "extent": 1.5
      },
      "encoding": {
        "x": {"field": labels.xLab.value,"type": "ordinal"},
        "y": {
          "field": labels.yLab.value,
          "type": "quantitative",
          "axis": {"title": labels.yLab.value}
        },
        "size": {"value": 5}
      }
    }

    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )
