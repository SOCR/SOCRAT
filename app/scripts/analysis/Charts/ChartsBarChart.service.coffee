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

  drawBar: (width,height,data,_graph,labels,ranges) ->

    for item in data
      item["x_vals"] = item["x"]
      item["y_vals"] = item["y"]

    if data[0]["z"]
      vlSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
        "width": 500,
        "height": 500,
        "data": {"values": data},
        "layer": [{
          "selection": {
            "brush": {
              "type": "interval",
              "encodings": ["x"]
            }
          },
          "mark": "bar",
          "encoding": {
            "x": {
              "field": "x_vals",
              "type": "ordinal",
              "axis": {"title": labels.xLab.value}
            },
            "y": {
              "aggregate": "mean",
              "field": "y_vals",
              "type": "quantitative",
              "axis": {"title": labels.yLab.value}
            },
            "color": {
              "field": "z",
              "type": "nominal",
              "scale": {"scheme": "category20b"}
            },
            "opacity": {
              "condition": {
                "selection": "brush", "value": 1
              },
              "value": 0.7
            }
          }
        }, {
          "transform": [{
            "filter": {"selection": "brush"}
          }],
          "mark": "rule",
          "encoding": {
            "y": {
              "aggregate": "mean",
              "field": "y_vals",
              "type": "quantitative"
            },
            "color": {"value": "firebrick"},
            "size": {"value": 3}
          }
        }]
      }
    else
      vlSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
        "width": 500,
        "height": 500,
        "data": {"values": data},
        "layer": [{
          "selection": {
            "brush": {
              "type": "interval",
              "encodings": ["x"]
            }
          },
          "mark": "bar",
          "encoding": {
            "x": {
              "field": "x_vals",
              "type": "ordinal",
              "axis": {"title": labels.xLab.value}
            },
            "y": {
              "aggregate": "mean",
              "field": "y_vals",
              "type": "quantitative",
              "axis": {"title": labels.yLab.value}
            },
            "opacity": {
              "condition": {
                "selection": "brush", "value": 1
              },
              "value": 0.7
            }
          }
        }, {
          "transform": [{
            "filter": {"selection": "brush"}
          }],
          "mark": "rule",
          "encoding": {
            "y": {
              "aggregate": "mean",
              "field": "y_vals",
              "type": "quantitative"
            },
            "color": {"value": "firebrick"},
            "size": {"value": 3}
          }
        }]
      }

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve '#vis', vlSpec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
      return
