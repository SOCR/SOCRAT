
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
    @vt = require 'vega-tooltip/build/vega-tooltip.js'

  drawScatterPlot: (data, labels, container, flags) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

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
            "x": {"field": labels.xLab.value,"type": "quantitative", "axis": {"title": labels.xLab.value}},
            "y": {"field": labels.yLab.value,"type": "quantitative", "axis": {"title": labels.yLab.value}}
          }
        },{
          "transform": [
            {
              "aggregate": [
                {"op": "mean", "field": labels.yLab.value, "as": "mean_"},
                {"op": "stdev", "field": labels.yLab.value, "as": "dev_"}
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
      if labels["zLab"].value and labels["zLab"].value isnt "None"
        vlSpec["layer"][0]["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "scale": {"scheme": "category20b"}}

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
            "field": labels.xLab.value, "type": "quantitative", "axis": {"title": labels.xLab.value}
          },
          "y": {
            "field": labels.yLab.value, "type": "quantitative", "axis": {"title": labels.yLab.value}
          }
        }
      }
      if labels["zLab"].value and labels["zLab"].value isnt "None"
        vlSpec["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "scale": {"scheme": "category20b"}}

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )
