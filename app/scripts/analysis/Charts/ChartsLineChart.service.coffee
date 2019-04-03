'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsLineChart extends BaseService
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

  lineChart: (data,labels,container) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "width": 500,
      "height": 500,
      "data": {"values": data},
      "mark": "line",
      "encoding": {
        "x": {
          "field": labels.xLab.value, "type": "temporal", "axis": {"title": labels.xLab.value}
        },
        "y": {
          "aggregate": "sum", "field": labels.yLab.value, "type": "quantitative", "axis": {"title": labels.yLab.value}
        }
      }
    }

    if labels["zLab"].value and labels["zLab"].value is not "None"
      vlSpec["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal"}

    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )
