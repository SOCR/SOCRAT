'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsScatterPlot extends BaseService
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

  drawScatterPlot: (data,ranges,width,height,_graph,container,labels, flags) ->

    if (data[0]["z"])
      if flags.showSTDEV
        vlSpec = {
          "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
          "description": "A scatterplot",
          "data": {"values" : data},
          "width": 500,
          "height": 500,
          "layer": [{
            "mark": "circle",
            "encoding": {
              "x": {"field": "x","type": "quantitative", "axis": {"title": labels.xLab.value}},
              "y": {"field": "y","type": "quantitative", "axis": {"title": labels.yLab.value}},
              "color": {"field": "z", "type": "nominal", "axis": {"title": labels.zLab.value}}
            }
          },{
            "transform": [
              {
                "aggregate": [
                  {"op": "mean", "field": "y", "as": "mean_"},
                  {"op": "stdev", "field": "y", "as": "dev_"}
                ],
                "groupby": []
              },
              {
                "calculate": "datum.mean_-datum.dev_",
                "as": "lower"
              },
              {
                "calculate": "datum.mean_+datum.dev_",
                "as": "upper"
              }
            ],
            "layer": [{
              "mark": "rule",
              "encoding": {
                "y": {"field": "mean_","type": "quantitative", "axis": null}
              }
            },{
              "selection": {
                "grid": {
                  "type": "interval", "bind": "scales"
                }
              },
              "mark": "rect",
              "encoding": {
                "y": {"field": "lower","type": "quantitative", "axis": null},
                "y2": {"field": "upper","type": "quantitative"},
                "opacity": {"value": 0.2}
              }
            }]
          }]
        }
      else
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
            },
            "color": {"field": "z", "type": "nominal", "axis": {"title": labels.zLab.value}}
          }
        }
    else
      if flags.showSTDEV
        vlSpec = {
          "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
          "description": "A scatterplot",
          "data": {"values" : data},
          "width": 500,
          "height": 500,
          "selection": {
            "grid": {
              "type": "interval", "bind": "scales"
            }
          },
          "layer": [{
            "mark": "circle",
            "encoding": {
              "x": {"field": "x","type": "quantitative", "axis": {"title": labels.xLab.value}},
              "y": {"field": "y","type": "quantitative", "axis": {"title": labels.yLab.value}},
            }
          },{
            "transform": [
              {
                "aggregate": [
                  {"op": "mean", "field": "y", "as": "mean_"},
                  {"op": "stdev", "field": "y", "as": "dev_"}
                ],
                "groupby": []
              },
              {
                "calculate": "datum.mean_-datum.dev_",
                "as": "lower"
              },
              {
                "calculate": "datum.mean_+datum.dev_",
                "as": "upper"
              }
            ],
            "layer": [{
              "mark": "rule",
              "encoding": {
                "y": {"field": "mean_","type": "quantitative", "axis": null}
              }
            },{
              "mark": "rect",
              "encoding": {
                "y": {"field": "lower","type": "quantitative", "axis": null},
                "y2": {"field": "upper","type": "quantitative"},
                "opacity": {"value": 0.2}
              }
            }]
          }]
        }
      else
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

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve '#vis', vlSpec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
      return
