
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

  getName: () ->
    return 'Scatter Plot'

  drawScatterPlot: (data, labels, container, flags) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    if flags.showSTDEV

#      mean_x = "mean_" + labels.xLab.value
#      std_x = "standard_deviation_" + labels.xLab.value
#      upper_x = "upper_" + labels.xLab.value
#      lower_x = "lower_" + labels.xLab.value
#      mean_y = "mean_" + labels.yLab.value
#      std_y = "standard_deviation_" + labels.yLab.value
#      upper_y = "upper_" + labels.yLab.value
#      lower_y = "lower_" + labels.yLab.value

      vlSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
        "description": "A scatterplot",
        "data": {"values" : data},
        "width": 500,
        "height": 500,
        "layer": [{
          "mark": "circle",
          "encoding": {
            "x": {"field": labels.xLab.value,"type": "quantitative", "axis": {"title": labels.xLab.value}}
          }
        },
        {
          "transform": [
            {
              "aggregate": [
                {"op": "mean", "field": labels.xLab.value, "as": "mean_x"},
                {"op": "stdev", "field": labels.xLab.value, "as": "stdev_x"}
              ],
              "groupby": []
            },
            {
              "calculate": "datum.mean_x-datum.stdev_x",
              "as": "lower_x"
            },
            {
              "calculate": "datum.mean_x+datum.stdev_x",
              "as": "upper_x"
            }
          ],
          "layer": [
            {
              "mark": "rule",
              "encoding": {
                "x": {"field": "mean_x", "type": "quantitative", "axis": null}
              }
            },
            {
              "selection": {"grid_x": {"type": "interval", "bind": "scales"}},
              "mark": "rect",
              "encoding": {
                "x": {"field": "lower_x", "type": "quantitative", "axis": null},
                "x2": {"field": "upper_x", "type": "quantitative"},
                "opacity": {"value": 0.2}
              }
            }
          ]
        }]
      }

      if labels.yLab.value is "Count"
        vlSpec["layer"][0]["encoding"]["y"] = {"aggregate": "count", "field": labels.xLab.value,"type": "quantitative", "title": "Count"}
      else
        vlSpec["layer"][0]["encoding"]["y"] = {"field": labels.yLab.value,"type": "quantitative", "axis": {"title": labels.yLab.value}}
        mean_y = {"op": "mean", "field": labels.yLab.value, "as": "mean_y"}
        stdev_y = {"op": "stdev", "field": labels.yLab.value, "as": "stdev_y"}
        vlSpec["layer"][1]["transform"][0]["aggregate"].push(mean_y, stdev_y)
        lower_y = {"calculate": "datum.mean_y-datum.stdev_y", "as": "lower_y"}
        upper_y = {"calculate": "datum.mean_y+datum.stdev_y", "as": "upper_y"}
        vlSpec["layer"][1]["transform"].push(lower_y, upper_y)
        rule_y = {
          "mark": "rule",
          "encoding": {
            "y": {"field": "mean_y", "type": "quantitative", "axis": null}
          }
        }
        rect_y = {
          "selection": {
            "brush": {
              "type": "interval",
              "encodings": ["x", "y"],
              "on": "[mousedown[!event.shiftKey], window:mouseup] > window:mousemove!",
              "translate": "[mousedown[!event.shiftKey], window:mouseup] > window:mousemove!",
              "zoom": "wheel!",
              "mark": {"fill": "#333", "fillOpacity": 0.125, "stroke": "white"},
              "resolve": "global"
            },
            "grid": {
              "type": "interval",
              "bind": "scales",
              "on": "[mousedown[event.shiftKey], window:mouseup] > window:mousemove!",
              "encodings": ["x", "y"],
              "translate": "[mousedown[event.shiftKey], window:mouseup] > window:mousemove!",
              "zoom": "wheel!",
              "mark": {"fill": "#333", "fillOpacity": 0.125, "stroke": "white"},
              "resolve": "global"
            }
          },
          "mark": "rect",
          "encoding": {
            "y": {"field": "lower_y", "type": "quantitative", "axis": null},
            "y2": {"field": "upper_y", "type": "quantitative"},
            "opacity": {"value": 0.2}
          }
        }
        vlSpec["layer"][1]["layer"].push(rule_y, rect_y)
        if flags.binned
          vlSpec["layer"][0]["encoding"]["x"]["bin"] = {"maxbins": 10}
          vlSpec["layer"][0]["encoding"]["y"]["bin"] = {"maxbins": 10}
          vlSpec["layer"][0]["encoding"]["size"] = {"aggregate": "count", "type": "quantitative"}

      if labels["zLab"].value and labels["zLab"].value isnt "None"
        vlSpec["layer"][0]["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "scale": {"scheme": "category20b"}}

    else
      vlSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
        "width": 500,
        "height": 500,
        "data": {"values": data},
        "selection": {
          "brush": {
            "type": "interval",
            "encodings": ["x", "y"],
            "on": "[mousedown[!event.shiftKey], window:mouseup] > window:mousemove!",
            "translate": "[mousedown[!event.shiftKey], window:mouseup] > window:mousemove!",
            "zoom": "wheel!",
            "mark": {"fill": "#333", "fillOpacity": 0.125, "stroke": "white"},
            "resolve": "global"
          },
          "grid": {
            "type": "interval",
            "bind": "scales",
            "on": "[mousedown[event.shiftKey], window:mouseup] > window:mousemove!",
            "encodings": ["x", "y"],
            "translate": "[mousedown[event.shiftKey], window:mouseup] > window:mousemove!",
            "zoom": "wheel!",
            "mark": {"fill": "#333", "fillOpacity": 0.125, "stroke": "white"},
            "resolve": "global"
          }
        },
        "mark": "circle",
        "encoding": {
          "x": {
            "field": labels.xLab.value, "type": "quantitative", "axis": {"title": labels.xLab.value}
          }
        }
      }
      if labels.yLab.value is "Count"
        vlSpec["encoding"]["y"] = {"aggregate": "count", "field": labels.xLab.value,"type": "quantitative", "title": "Count"}
      else
        vlSpec["encoding"]["y"] = {"field": labels.yLab.value,"type": "quantitative", "axis": {"title": labels.yLab.value}}
        if flags.binned
          vlSpec["encoding"]["x"]["bin"] = {"maxbins": 10}
          vlSpec["encoding"]["y"]["bin"] = {"maxbins": 10}
          vlSpec["encoding"]["size"] = {"aggregate": "count", "type": "quantitative"}

      if labels["zLab"].value and labels["zLab"].value isnt "None"
        vlSpec["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "scale": {"scheme": "category20b"}}

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )
