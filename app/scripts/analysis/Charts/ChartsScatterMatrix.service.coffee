'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsScatterMatrix extends BaseService
  @inject '$q',
    '$stateParams',
    'app_analysis_charts_dataTransform',
    'app_analysis_charts_list',
    'app_analysis_charts_sendData',
    'app_analysis_charts_checkTime',
    'app_analysis_charts_dataService',
    'app_analysis_charts_msgService',

  initialize: ->
    @msgService = @app_analysis_charts_msgService
    @dataService = @app_analysis_charts_dataService
    @dataTransform = @app_analysis_charts_dataTransform
    @list = @app_analysis_charts_list
    @sendData = @app_analysis_charts_sendData
    @checkTime = @app_analysis_charts_checkTime
    @DATA_TYPES = @dataService.getDataTypes()

    @ve = require('vega-embed').default
    @vt = require 'vega-tooltip'

  drawScatterMatrix: (data, labels, container) ->

    # labels here is different from that for other charts
    # fields are the same as labels for other charts

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    fields = data.splice(0, 1)[0]

    index_x = fields.indexOf("x");
    index_y = fields.indexOf("y");

    if index_x isnt -1
      fields[index_x] = "x_vals"

    if index_y isnt -1
      fields[index_y] = "y_vals"

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
      "$schema": "https://vega.github.io/schema/vega-lite/v4.json",
      "description": "A simple bar chart with embedded data.",
      "data": {
        "values": [
          {"a": "A", "b": 28}, {"a": "B", "b": 55}, {"a": "C", "b": 43},
          {"a": "D", "b": 91}, {"a": "E", "b": 81}, {"a": "F", "b": 53},
          {"a": "G", "b": 19}, {"a": "H", "b": 87}, {"a": "I", "b": 52}
        ]
      },
      "mark": "bar",
      "encoding": {
        "x": {"field": "a", "type": "nominal", "axis": {"labelAngle": 0}},
        "y": {"field": "b", "type": "quantitative"}
      }
    }

    # vlSpec = {
    #   "$schema": "https://vega.github.io/schema/vega-lite/v4.json",
    #   "repeat": {
    #     "row": fields,
    #     "column": fields
    #   },
    #   "spec": {
    #     "data": {"values": d},
    #     "mark": "point",
    #     "selection": {
    #       "brush": {
    #         "type": "interval",
    #         "encodings": ["x", "y"],
    #         "on": "[mousedown[!event.shiftKey], window:mouseup] > window:mousemove!",
    #         "translate": "[mousedown[!event.shiftKey], window:mouseup] > window:mousemove!",
    #         "zoom": "wheel!",
    #         "mark": {"fill": "#333", "fillOpacity": 0.125, "stroke": "white"},
    #         "resolve": "global"
    #       },
    #       "grid": {
    #         "type": "interval",
    #         "bind": "scales",
    #         "on": "[mousedown[event.shiftKey], window:mouseup] > window:mousemove!",
    #         "encodings": ["x", "y"],
    #         "translate": "[mousedown[event.shiftKey], window:mouseup] > window:mousemove!",
    #         "zoom": "wheel!",
    #         "mark": {"fill": "#333", "fillOpacity": 0.125, "stroke": "white"},
    #         "resolve": "global"
    #       }
    #     },
    #     "encoding": {
    #       "x": {"field": {"repeat": "column"}, "type": "quantitative"},
    #       "y": {"field": {"repeat": "row"}, "type": "quantitative"}
    #     }
    #   }
    # }

    # if labels
    #   vlSpec['spec']['encoding']['color'] = {
    #     "condition": {
    #       "selection": "brush",
    #       "field": ordinal,
    #       "type": "nominal"
    #     },
    #     "value": "grey"
    #   }

#    vlSpec["config"] =
#      "axis":
#        "titleFontSize": 16
#        "labelFontSize": 16
#      "title":
#        "titleFontSize": 16
#      "legend":
#          "labelFontSize": 16
#          "titleFontSize": 16
#      "point":
#        "size": 80

    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )
