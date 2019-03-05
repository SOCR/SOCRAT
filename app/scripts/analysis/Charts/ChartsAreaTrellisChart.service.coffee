'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsAreaTrellisChart extends BaseService
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

    @ve = require 'vega-embed'
    @vt = require 'vega-tooltip/build/vega-tooltip.js'

  areaTrellisChart: (data, labels, container) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "width": 500,
      "height": 500,
      "data": {"values": data},
      "mark": "line",
      "encoding": {
        "x": {"field": "x", "type": "temporal", "axis": {"title": labels.xLab.value}},
        "y": {"field": "y", "type": "quantitative", "axis": {"title": labels.yLab.value}}
      }
    }

    if labels["zLab"].value and labels["zLab"].value isnt "None"
      vlSpec["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "legend": null}
      vlSpec["encoding"]["row"] = {"field": "labels.zLab.value", "type": "nominal", "header": {"title": "labels.zLab.value"}
      }

    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )
