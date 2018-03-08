'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsAreaChart extends BaseService
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

  drawArea: (height,width,_graph, data, labels) ->

    for item in data
      item["x_vals"] = item["x"]
      item["y_vals"] = item["y"]

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "width": 500,
      "height": 500,
      "data": {"values": data},
      "mark": "area",
      "encoding": {
        "x": {
          "field": "x_vals",
          "type": "temporal",
          "axis": {"title": labels.xLab.value},
        },
        "y": {
          "aggregate": "sum",
          "field": "y_vals",
          "type": "quantitative",
          "axis": {"title": labels.yLab.value},
        }
      }
    }

    opt =
      "actions": {export: true, source: false, editor: false}
    
    @ve '#vis', vlSpec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
      return