'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsTrellisChart extends BaseService
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

  drawTrellis: (width, height, data, _graph, labels, container) ->

    mark = "point"

    fields = data.splice(0, 1)[0]
    if labels
      ordinal = labels.splice(0, 1)[0]

    d = []
    for row, row_ind in data
      row_obj = {}
      for label, lbl_idx in fields
        row_obj[label] = row[lbl_idx]
      if labels
        row_obj[ordinal] = labels[row_ind]
      d.push row_obj

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "repeat": {
        "row": fields,
        "column": fields
      },
      "spec": {
        "data":
          "values": d,
        "mark": "point",
        "selection": {
          "brush": {
            "type": "interval",
            "resolve": "union",
            "on": "[mousedown[event.shiftKey], window:mouseup] > window:mousemove!",
            "translate": "[mousedown[event.shiftKey], window:mouseup] > window:mousemove!",
            "zoom": "wheel![event.shiftKey]"
          },
          "grid": {
            "type": "interval",
            "resolve": "global",
            "bind": "scales",
            "translate": "[mousedown[!event.shiftKey], window:mouseup] > window:mousemove!",
            "zoom": "wheel![!event.shiftKey]"
          }
        },
        "encoding": {
          "x": {"field": {"repeat": "column"},"type": "quantitative"},
          "y": {"field": {"repeat": "row"},"type": "quantitative"},
          "color": null
        }
      }
    }

    if labels
      vlSpec['spec']['encoding']['color'] = {
        "condition": {
          "selection": "brush",
          "field": ordinal,
          "type": "nominal"
        },
        "value": "grey"
      }
    else
      vlSpec['spec']['encoding']['color'] = null

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve '#vis', vlSpec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
      return
