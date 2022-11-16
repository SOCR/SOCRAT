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
    @ve = @list.getVegaEmbed()
    @vt = @list.getVegaTooltip()
    @schema = @list.getVegaLiteSchema()

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
      "$schema": @schema,
      "repeat": {
        "row": fields,
        "column": fields
      },
      "spec": {
        "data": {"values": d},
        "mark": "point",
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
        "encoding": {
          "x":
            "field": {"repeat": "column"},
            "type": "quantitative",
            # "axis":
            #   "titleFontSize": 20,
            #   "labelFontSize": 20,
          "y":
            "field": {"repeat": "row"},
            "type": "quantitative",
            # "axis":
            #   "titleFontSize": 20,
            #   "labelFontSize": 20
        }
      }
    }

    if labels?
      vlSpec['spec']['encoding']['color'] = {
        "condition": {
          "selection": "brush",
          "field": ordinal,
          "type": "nominal"
        },
        "value": "grey"
        # "legend": {"labelFontSize": 20}
      }

    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )
