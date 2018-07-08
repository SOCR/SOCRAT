'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBinnedHeatmapChart extends BaseService
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

  drawHeatmap: (data, ranges, width, height, _graph, labels, flags) ->

    if flags.marginalHistogram
      vlSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
        "data": {"values" : data},
        "spacing": 15,
        "bounds": "flush",
        "vconcat": [{
          "mark": "bar",
          "width" : 500,
          "height": 100,
          "encoding": {
            "x": {
              "bin": {"maxbins" : flags.xBin},
              "field": "x",
              "type": "quantitative",
              "axis": null
            },
            "y": {
              "aggregate": "count",
              "type": "quantitative",
              "title": ""
            }
          }
        }, {
          "spacing": 15,
          "bounds": "flush",
          "hconcat": [{
            "width" : 500,
            "height" : 500,
            "mark": "rect",
            "encoding": {
              "x": {
                "bin": {"maxbins" : flags.xBin},
                "field": "x",
                "type": "quantitative",
                "axis": {"title": labels.xLab.value}
              },
              "y": {
                "bin": {"maxbins" : flags.yBin},
                "field": "y",
                "type": "quantitative",
                "axis": {"title": labels.yLab.value}
              },
              "color": {
                "field" : "z"
                "aggregate": "mean",
                "type": "quantitative",
                "legend": {
                  "title": labels.zLab.value
                }
              }
            }
          }, {
            "mark": "bar",
            "height" : 500,
            "width": 100,
            "encoding": {
              "y": {
                "bin": {"maxbins" : flags.yBin},
                "field": "y",
                "type": "quantitative",
                "axis": null
              },
              "x": {
                "aggregate": "count",
                "type": "quantitative",
                "title": ""
              }
            }
          }]
        }],
        "config": {
          "range": {
            "heatmap": {
              "scheme": "greenblue"
            }
          }
        }
      }
    else
      vlSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
        "data": {"values": data},
        "mark": "rect",
        "width": 500,
        "height": 500,
        "encoding": {
          "x": {
            "bin" : {"maxbins" : flags.xBin}
            "field": "x",
            "type": "quantitative",
            "axis": {"title": labels.xLab.value}
          },
          "y": {
            "bin" : {"maxbins" : flags.yBin}
            "field": "y",
            "type": "quantitative",
            "axis": {"title": labels.yLab.value}
          },
          "color": {
            "aggregate" : "mean",
            "field" : "z",
            "type": "quantitative",
            "legend": {
              "title": labels.zLab.value
            }
          }
        },
        "config" : {
          "range" : {"heatmap" : {"scheme" : "greenblue"}}
        }
      }

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve '#vis', vlSpec, opt, (error, result) ->
    # Callback receiving the View instance and parsed Vega spec
    # result.view is the View, which resides under the '#vis' element
      return
