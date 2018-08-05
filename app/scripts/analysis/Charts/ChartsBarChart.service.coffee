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

  drawBar: (data, labels, container, flags) ->

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

    # vertical
    if !flags.Horizontal
      # stack: aggregate with count, no mean/threshold overlay
      # if color, can toggle normalize option
      if flags.Stacked
        vlSpec = {
          "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
          "width": 500,
          "height": 500,
          "data": {"values": data},
          "mark": "bar",
          "encoding": {
            "x": {
              "field": labels.xLab.value,
              "type": "ordinal",
              "axis": {"title": labels.xLab.value}
            },
            "y": {
              "aggregate": "count",
              "type": "quantitative"
            }
          }
        }
      # not stacked
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
                      "encodings": ["x"]
                    }
                  },
                  "mark": "bar",
                  "encoding": {
                    "x": {
                      "field": labels.xLab.value,
                      "type": "ordinal",
                      "axis": {"labelAngle": 0, "title": labels.xLab.value}
                    },
                    "y": {
                      "field": labels.yLab.value,
                      "type": "quantitative",
                      "title": labels.yLab.value
                    }
                  }
                },
                {
                  "mark": "bar",
                  "transform": [
                    {"filter": {"field": labels.yLab.value, "gt": flags.threshold}},
                    {"calculate": flags.threshold, "as": "baseline"}
                  ],
                  "encoding": {
                    "x": {"field": labels.xLab.value, "type": "ordinal"},
                    "y": {"field": "baseline", "type": "quantitative"},
                    "y2": {"field": labels.yLab.value, "type": "quantitative"},
                    "color": {"value": "#e45755"}
                  }
                },
                {
                  "transform": [{"filter": {"selection": "brush"}}],
                  "layer": [{
                    "mark": "rule",
                    "encoding": {
                      "y": {
                        "aggregate": "mean",
                        "field": labels.yLab.value,
                        "type": "quantitative"
                      },
                      "color": {"value": "firebrick"},
                      "size": {"value": 3}
                    }
                  }]
                }
              ]
            },
            {
              "data": {"values": [{"ThresholdValue": flags.threshold, "Threshold": "hazardous"}]},
              "layer": [
                {
                  "mark": "rule",
                  "encoding": {"y": {"field": "ThresholdValue", "type": "quantitative"}}
                },
                {
                  "mark": {"type": "text", "align": "right", "dx": -2, "dy": -4},
                  "encoding": {
                    "x": {"value": "width"},
                    "y": {
                      "field": "ThresholdValue",
                      "type": "quantitative",
                      "axis": {"title": labels.yLab.value}
                    },
                    "text": {"field": "Threshold", "type": "ordinal"}
                  }
                }
              ]
            }
          ]
        }
    # horizontal
    else
      if flags.Stacked
        vlSpec = {
          "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
          "width": 500,
          "height": 500,
          "data": {"values": data},
          "mark": "bar",
          "encoding": {
            "x": {
              "aggregate": "count",
              "type": "quantitative"
            },
            "y": {
              "field": labels.xLab.value,
              "type": "ordinal",
              "axis": {"title": labels.xLab.value}
            }
          }
        }
      # not stacked
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
                      "encodings": ["y"]
                    }
                  },
                  "mark": "bar",
                  "encoding": {
                    "x": {
                      "field": labels.yLab.value,
                      "type": "quantitative",
                      "title": labels.yLab.value
                    },
                    "y": {
                      "field": labels.xLab.value,
                      "type": "ordinal",
                      "title": labels.xLab.value
                    }
                  }
                },
                {
                  "mark": "bar",
                  "transform": [
                    {"filter": {"field": labels.yLab.value, "gt": "1"}},
                    {"calculate": "1", "as": "baseline"}
                  ],
                  "encoding": {
                    "x": {"field": labels.yLab.value, "type": "quantitative"},
                    "x2": {"field": "baseline", "type": "ordinal"},
                    "y2": {"field": labels.xLab.value, "type": "ordinal"},
                    "color": {"value": "#e45755"}
                  }
                },
                {
                  "transform": [{"filter": {"selection": "brush"}}],
                  "layer": [
                    {
                      "mark": "rule",
                      "encoding": {
                        "x": {
                          "aggregate": "mean",
                          "field": labels.yLab.value,
                          "type": "quantitative"
                        },
                        "color": {"value": "firebrick"},
                        "size": {"value": 3}
                      }
                    }
                  ]
                }
              ]
            },
            {
              "data": {"values": [{"ThresholdValue": flags.threshold, "Threshold": "hazardous"}]},
              "layer": [
                {
                  "mark": "rule",
                  "encoding": {"x": {"field": "ThresholdValue", "type": "quantitative"}}
                },
                {
                  "mark": {"type": "text", "dx": -2, "dy": -4},
                  "encoding": {
                    "x": {
                      "field": "ThresholdValue",
                      "type": "quantitative",
                      "axis": {"title": labels.yLab.value}
                    },
                    "y": {"value": "height"},
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
          if flags.Horizontal
            vlSpec["encoding"]["x"]["stack"] = "normalize"
          else
            vlSpec["encoding"]["y"]["stack"] = "normalize"
      else
        vlSpec["layer"][0]["layer"][0]["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "scale": {"scheme": "category20b"}, "legend": {"title": labels.zLab.value}}



    opt =
      "actions": {export: true, source: false, editor: true}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )
