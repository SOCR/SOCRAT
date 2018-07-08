'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsStripPlot extends BaseService
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

  drawStripPlot: (data,ranges,width,height,_graph,labels) ->

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "description": "Shows the relationship between X and Y using tick marks.",
      "width" : 500,
      "height" : 500,
      "data": {"values" : data},
      "mark": "tick",
      "encoding": {
        "x": {"field" : "x", "axis": {"title" : labels.xLab.value} , "type": "quantitative"},
        "y": {"field" : "y", "axis" : {"title": labels.yLab.value}, "type": "ordinal"}
      }
    }

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve '#vis', vlSpec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
      return
