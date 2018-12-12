
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

    x_ = labels.xLab.value
    y_ = labels.yLab.value

    sumx = 0
    sumy = 0
    for dic in data
      sumx += parseFloat(dic[x_])
      sumy += parseFloat(dic[y_])

    mean_x = sumx/data.length
    mean_y = sumy/data.length

    for dic in data
      dic["residual_x"] = dic[x_] - mean_x
      dic["residual_y"] = dic[y_] - mean_y

    if (flags.x_residual)
      x_ = "residual_x"

    if (flags.y_residual)
      y_ = "residual_y"

    if flags.showSTDEV

      vlSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
        "description": "A scatterplot",
        "data": {"values" : data},
        "width": 500,
        "height": 500,
        "layer": [{
          "transform": [
            {
              "aggregate": [
              ],
              "groupby": []
            }
          ],
          "layer": [
          ]
        },
        {
          "mark": "circle",
          "encoding": {
          }
        }]
      }

      vlSpec["layer"][1]["encoding"]["x"] = {"field": x_,"type": "quantitative", "axis": {"title": x_}}
      mean_x = {"op": "mean", "field": x_, "as": "mean_x"}
      stdev_x = {"op": "stdev", "field": x_, "as": "stdev_x"}
      vlSpec["layer"][0]["transform"][0]["aggregate"].push(mean_x, stdev_x)
      lower_x = {"calculate": "datum.mean_x-datum.stdev_x", "as": "lower_x"}
      upper_x = {"calculate": "datum.mean_x+datum.stdev_x", "as": "upper_x"}
      vlSpec["layer"][0]["transform"].push(lower_x, upper_x)
      rule_x = {
        "mark": "rule",
        "encoding": {
          "x": {"field": "mean_x", "type": "quantitative", "axis": null}
        }
      }
      rect_x = {
        "mark": "rect",
        "encoding": {
          "x": {"field": "lower_x", "type": "quantitative", "axis": null},
          "x2": {"field": "upper_x", "type": "quantitative"},
          "opacity": {"value": 0.2}
        }
      }
      vlSpec["layer"][0]["layer"].push(rule_x, rect_x)

      if flags.opacity
        vlSpec["layer"][1]["encoding"]["opacity"] = {
          "aggregate": "count",
          "type": "quantitative"
        }
      if labels["zLab"].value and labels["zLab"].value isnt "None"
        vlSpec["layer"][1]["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "scale": {"scheme": "category20b"}}
      if labels["rLab"].value and labels["rLab"].value isnt "None"
        vlSpec["layer"][1]["encoding"]["size"] = {"field": labels.rLab.value, "type": "quantitative", "scale": {"scheme": "category20b"}}


      if labels.yLab.value is "Count"
        vlSpec["layer"][1]["encoding"]["y"] = {"aggregate": "count", "field": x_, "type": "quantitative", "title": "Count"}
      else
        vlSpec["layer"][1]["encoding"]["y"] = {"field": y_,"type": "quantitative", "axis": {"title": y_}}
        mean_y = {"op": "mean", "field": y_, "as": "mean_y"}
        stdev_y = {"op": "stdev", "field": y_, "as": "stdev_y"}
        vlSpec["layer"][0]["transform"][0]["aggregate"].push(mean_y, stdev_y)
        lower_y = {"calculate": "datum.mean_y-datum.stdev_y", "as": "lower_y"}
        upper_y = {"calculate": "datum.mean_y+datum.stdev_y", "as": "upper_y"}
        vlSpec["layer"][0]["transform"].push(lower_y, upper_y)
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
        vlSpec["layer"][0]["layer"].push(rule_y, rect_y)
        if flags.binned
          vlSpec["layer"][1]["encoding"]["x"]["bin"] = {"maxbins": 10}
          vlSpec["layer"][1]["encoding"]["y"]["bin"] = {"maxbins": 10}
          vlSpec["layer"][1]["encoding"]["size"] = {"aggregate": "count", "type": "quantitative"}
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
            "field": x_, "type": "quantitative", "axis": {"title": x_}
          }
        }
      }
      if flags.opacity
        vlSpec["encoding"]["opacity"] = {
          "aggregate": "count",
          "type": "quantitative"
        }
      if labels["zLab"].value and labels["zLab"].value isnt "None"
        vlSpec["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "scale": {"scheme": "category20b"}}
      if labels["rLab"].value and labels["rLab"].value isnt "None"
        vlSpec["encoding"]["size"] = {"field": labels.rLab.value, "type": "quantitative", "scale": {"scheme": "category20b"}}

      if labels.yLab.value is "Count"
        vlSpec["encoding"]["y"] = {"aggregate": "count", "field": x_,"type": "quantitative", "title": "Count"}
      else
        vlSpec["encoding"]["y"] = {"field": y_,"type": "quantitative", "axis": {"title": y_}}
        if flags.binned
          vlSpec["encoding"]["x"]["bin"] = {"maxbins": 10}
          vlSpec["encoding"]["y"]["bin"] = {"maxbins": 10}
          vlSpec["encoding"]["size"] = {"aggregate": "count", "type": "quantitative"}
    opt =
      "actions": {export: true, source: false, editor: false}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )
