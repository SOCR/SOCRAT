'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

<<<<<<< HEAD
module.exports = class ChartsAreaChart extends BaseService
=======
module.exports = class ChartsScatterPlot extends BaseService
>>>>>>> df50d07590e14b0006ebb99e45eca8ccc901fd59
  @inject '$q',
    '$stateParams',
    'app_analysis_charts_dataTransform',
    'app_analysis_charts_list',
    'app_analysis_charts_sendData',
    'app_analysis_charts_checkTime',
    'app_analysis_charts_dataService',
<<<<<<< HEAD
    'app_analysis_charts_msgService',
=======
    'app_analysis_charts_msgService'
>>>>>>> df50d07590e14b0006ebb99e45eca8ccc901fd59

  initialize: ->
    @msgService = @app_analysis_charts_msgService
    @dataService = @app_analysis_charts_dataService
    @dataTransform = @app_analysis_charts_dataTransform
    @list = @app_analysis_charts_list
    @sendData = @app_analysis_charts_sendData
    @checkTime = @app_analysis_charts_checkTime
    @DATA_TYPES = @dataService.getDataTypes()

    @ve = require 'vega-embed'

  drawScatterPlot: (data,ranges,width,height,_graph,container,labels) ->

<<<<<<< HEAD
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
      "mark": "circle",
      "encoding": {
        "x": {
          "field": "x", "type": "quantitative", "axis": {"title": labels.xLab.value}
        },
        "y": {
          "field": "y", "type": "quantitative", "axis": {"title": labels.yLab.value}
        }
      }
    }
=======
    if (data[0]["z"])
      vlSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
        "width": 500,
        "height": 500,
        "data": {"values": data},
        "mark": "point",
        "encoding": {
          "x": {"field": "x", "type": "quantitative", "axis": {"title": labels.xLab.value}},
          "y": {"field": "y", "type": "quantitative", "axis": {"title": labels.yLab.value}},
          "color": {"field": "z", "type": "nominal"}
        }
      }
    else
      vlSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
        "width": 500,
        "height": 500,
        "data": {"values": data},
        "mark": "point",
        "encoding": {
          "x": {"field": "x", "type": "quantitative", "axis": {"title": labels.xLab.value}},
          "y": {"field": "y", "type": "quantitative", "axis": {"title": labels.yLab.value}}
        }
      }

>>>>>>> df50d07590e14b0006ebb99e45eca8ccc901fd59

    opt =
      "actions": {export: true, source: false, editor: false}
    
    @ve '#vis', vlSpec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
<<<<<<< HEAD
      return
=======
      return
>>>>>>> df50d07590e14b0006ebb99e45eca8ccc901fd59
