'use strict'

require 'vega-tooltip/build/vega-tooltip.css'
BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsRangedDotPlot extends BaseService
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
    @vt = require 'vega-tooltip/build/vega-tooltip.js'

  drawRangedDotPlot: (data, labels, container) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "data": {"values": data},
      "encoding": {
        "x": {
          "field": labels.xLab.value,
          "type": "quantitative",
          "axis": {
            "title": labels.xLab.value
          }
        },
        "y": {
          "field": labels.yLab.value,
          "type": "nominal",
          "axis": {
            "title": labels.yLab.value,
            "offset": 5,
            "ticks": false,
            "minExtent": 70,
            "domain": false
          }
        }
      },
      "layer": [
        {
          "mark": "line",
          "encoding": {
            "detail": {
              "field": labels.yLab.value,
              "type": "nominal"
            },
            "color": {"value": "#db646f"}
          }
        },
        {
          "mark": {
            "type": "point",
            "filled": true
          },
          "encoding": {
            "color": {
              "field": labels.zLab.value,
              "type": "nominal",
              "scale": {"scheme": "category20b"}
            },
            "size": {"value": 100},
            "opacity": {"value": 1}
          }
        }
      ]
    }

    opt = {mode: "vega-lite", "actions": {export: true, source: false, editor: false}}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )

