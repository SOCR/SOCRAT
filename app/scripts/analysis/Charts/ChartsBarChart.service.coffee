'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBarChart extends BaseService
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

  drawBar: (data, labels, container, flags) ->

    max = Math.max.apply Math, data.map((o) -> o[labels.yLab.value])
    threshold = if flags.threshold then flags.threshold else max

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    if labels.xLab.value is "x"
      labels.xLab.value = "x_vals"
      for item in data
        item["x_vals"] = item["x"]

    if labels.yLab.value is "y"
      labels.yLab.value = "y_vals"
      for item in data
        item["y_vals"] = item["y"]

    if !flags.Horizontal
      y = "y"
      x = "x"
      y2 = "y2"
    else
      y = "x"
      x = "y"
      y2 = "x2"

    if flags.Stacked
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
        "mark": "bar",
        "encoding": {
          "#{x}": {
            "field": labels.xLab.value,
            "type": "quantitative",
            "axis": {"title": labels.xLab.value}
          },
          "#{y}": {
            "aggregate": "count",
            "type": "quantitative"
          }
        }
      }
    else
      vlSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
        "layer": [
          {
            "data": {"values": data},
            "layer": [
              {
                "selection": {
                  "brush": {
                    "type": "interval",
                    "encodings": ["#{x}"]
                  }
                },
                "mark": "bar",
                "encoding": {
                  "#{x}": {
                    "field": labels.xLab.value,
                    "type": "ordinal",
                    "axis": {"labelAngle": 0, "title": labels.xLab.value}
                  },
                  "#{y}": {
                    "field": labels.yLab.value,
                    "type": "quantitative",
                    "title": labels.yLab.value
                  }
                }
              },
              {
                "mark": "bar",
                "transform": [
                  {"filter": {"field": labels.yLab.value, "gt": "#{threshold}"}},
                  {"calculate": "#{threshold}", "as": "baseline"}
                ],
                "encoding": {
                  "#{x}": {"field": labels.xLab.value, "type": "ordinal"},
                  "#{y2}": {"field": "baseline", "type": "quantitative"},
                  "#{y}": {"field": labels.yLab.value, "type": "quantitative"},
                  "color": {"value": "#e40f21"}
                }
              },
              {
                "transform": [{"filter": {"selection": "brush"}}],
                "layer": [{
                  "mark": "rule",
                  "encoding": {
                    "#{y}": {
                      "aggregate": "mean",
                      "field": labels.yLab.value,
                      "type": "quantitative"
                    }
                  }
                },
                {
                  "mark": {"type": "text", "align": "left", "dx": 2, "dy": -4},
                  "encoding": {
                    "#{x}": {"value": 0},
                    "#{y}": {
                      "aggregate": "mean",
                      "field": labels.yLab.value,
                      "type": "quantitative"
                    },
                    "size": {"value": 15},
                    "text": {"value": "mean", "type": "ordinal"}
                  }
                }]
              }
            ]
          },
          {
            "data": {"values": [{"ThresholdValue": "#{threshold}", "Threshold": "hazardous"}]},
            "layer": [
              {
                "mark": "rule",
                "encoding": {
                  "#{y}": {"field": "ThresholdValue", "type": "quantitative"}
                }
              },
              {
                "mark": {"type": "text", "align": "left", "dx": 2, "dy": -4},
                "encoding": {
                  "#{x}": {"value": 0},
                  "#{y}": {
                    "field": "ThresholdValue",
                    "type": "quantitative",
                    "axis": {"title": labels.yLab.value}
                  },
                  "size": {"value": 15},
                  "text": {"field": "Threshold", "type": "ordinal"}
                }
              }
            ]
          }
        ]
      }

    if labels["zLab"].value and labels["zLab"].value isnt "None"
      if flags.Stacked
        vlSpec["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "scale": {"scheme": "category20b"}, "legend": {"title": labels.zLab.value}}
        if flags.Normalized
          vlSpec["encoding"]["#{y}"]["stack"] = "normalize"
      else
        vlSpec["layer"][0]["layer"][0]["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "scale": {"scheme": "category20b"}, "legend": {"title": labels.zLab.value}}

    opt =
      "actions": {export: true, source: false, editor: true}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )
