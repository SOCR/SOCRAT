'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBoxPlot extends BaseService
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

  drawBoxPlot: (_graph, data, container, labels, width, height, ranges) ->

    # do not bin categorical X
    if labels.xLab.type is 'string'
      binX = off
      fieldX = 'x'
    else
      binX = on
      fieldX = 'bin_x'

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "description": "A vertical 2D box plot showing median, min, and max.",
      "data":
        "values": data,
      "transform": [
        {
          "bin": binX,
          "field": "x",
          "as": fieldX
        },
        {
          "aggregate": [
            {
              "op": "q1",
              "field": "y",
              "as": "lowerBox"
            },
            {
              "op": "q3",
              "field": "y",
              "as": "upperBox"
            },
            {
              "op": "median",
              "field": "y",
              "as": "midBox"
            }
          ],
          "groupby": [
            fieldX
          ]
        },
        {
          "calculate": "datum.upperBox - datum.lowerBox",
          "as": "IQR"
        },
        {
          "calculate": "datum.lowerBox - datum.IQR * 1.5",
          "as": "lowerWhisker"
        },
        {
          "calculate": "datum.upperBox + datum.IQR * 1.5",
          "as": "upperWhisker"
        }
      ],
      "layer": [
        {
          "mark": {
            "type": "rule",
            "style": "boxWhisker"
          },
          "encoding": {
            "y": {
              "field": "lowerWhisker",
              "type": "quantitative",
              "axis": {
                "title": labels.yLab.value
              }
            },
            "y2": {
              "field": "lowerBox",
              "type": "quantitative"
            },
            "x": {
              "field": fieldX,
              "type": "ordinal",
              "axis": {
                "title": labels.xLab.value
              }
            }
          }
        },
        {
          "mark": {
            "type": "rule",
            "style": "boxWhisker"
          },
          "encoding": {
            "y": {
              "field": "upperBox",
              "type": "quantitative"
            },
            "y2": {
              "field": "upperWhisker",
              "type": "quantitative"
            },
            "x": {
              "field": fieldX,
              "type": "ordinal"
            }
          }
        },
        {
          "mark": {
            "type": "bar",
            "style": "box"
          },
          "encoding": {
            "y": {
              "field": "lowerBox",
              "type": "quantitative"
            },
            "y2": {
              "field": "upperBox",
              "type": "quantitative"
            },
            "x": {
              "field": fieldX,
              "type": "ordinal"
            },
            "size": {
              "value": 5
            }
          }
        },
        {
          "mark": {
            "type": "tick",
            "style": "boxMid"
          },
          "encoding": {
            "y": {
              "field": "midBox",
              "type": "quantitative"
            },
            "x": {
              "field": fieldX,
              "type": "ordinal"
            },
            "color": {
              "value": "white"
            },
            "size": {
              "value": 5
            }
          }
        }
      ]
    }

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve '#vis', vlSpec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
      return
