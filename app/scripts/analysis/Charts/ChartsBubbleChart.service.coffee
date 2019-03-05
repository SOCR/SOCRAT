'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBubbleChart extends BaseService
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

  drawBubble: (data,labels,container) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

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
      "selection": {
        "grid": {
          "type": "interval", "bind": "scales"
        }
      },
      "mark": "circle",
      "encoding": {
        "x": {
          "field": labels.xLab.value,
          "type": "quantitative",
          "axis": {"title": labels.xLab.value}
        },
        "y": {
          "field": labels.yLab.value,
          "type": "quantitative",
          "axis": {"title": labels.yLab.value}
        },
        "opacity": {
          "aggregate": "count",
          "type": "quantitative"
        }
      }
    }

    if labels["zLab"].value and labels["zLab"].value isnt "None"
      vlSpec["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "scale": {"scheme": "category20b"}}

    if labels["rLab"].value and labels["rLab"].value isnt "None"
      vlSpec["encoding"]["size"] = {"field": labels.rLab.value, "type": "quantitative", "scale": {"scheme": "category20b"}}


    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )
