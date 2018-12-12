'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsTrellisChart extends BaseService
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
    @vt = require 'vega-tooltip/build/vega-tooltip.js'

  drawTrellis: (data, labels, container) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "data": {"values": data},
      "selection": {
        "brush": {
          "type": "interval",
          "bind": "scales",
          "encodings": ["x", "y"]
        }
      },
      "mark": "point",
      "encoding": {
        "row": {
          "field": labels.rLab.value, "type": "ordinal",
          "sort": {"op": "median", "field": labels.xLab.value}
        },
        "x": {
          "aggregate": "median", "field": labels.xLab.value, "type": "quantitative",
          "scale": {"zero": false}
        },
        "y": {
          "field": labels.yLab.value, "type": "quantitative",
          "sort": {"field": labels.xLab.value,"op": "median", "order": "descending"},
          "scale": {"rangeStep": 12}
        }
      }
    }

    if labels["zLab"].value and labels["zLab"].value isnt "None"
      vlSpec["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "scale": {"scheme": "category20b"}, "legend": {"title": labels.zLab.value}}

    opt =
      "actions": {export: true, source: false, editor: true}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )
