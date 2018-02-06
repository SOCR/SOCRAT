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
      row_obj[ordinal] = labels[row_ind]
      d.push row_obj

    vSpec = {
      "width": 180 * fields.length,
      "height": 180 * fields.length,
      "data": [
        {
          "name": "iris",
          "values": d
        },
        {
          "name": "fields",
          "values": fields
        }
      ],
      "signals": [
        {
          "name": "cell",
          "init": {},
          "streams": [
            {"type": "@cell:mousedown, @point:mousedown", "expr": "eventGroup()"}
          ]
        },
        {
          "name": "start_coords",
          "init": {},
          "streams": [{
            "type": "@cell:mousedown, @point:mousedown",
            "expr": "{x: clamp(eventX(cell), 0, cell.width), y: clamp(eventY(cell), 0, cell.height)}"
          }]
        },
        {
          "name": "end_coords",
          "init": {},
          "streams": [{
            "type": "@cell:mousedown, @point:mousedown, [(@cell:mousedown, @point:mousedown), window:mouseup] > window:mousemove",
            "expr": "{x: clamp(eventX(cell), 0, cell.width), y: clamp(eventY(cell), 0, cell.height)}"
          }]
        },
        {
          "name": "start_data",
          "init": {},
          "expr": "{x: iscale('x', start_coords.x, cell), y: iscale('y', start_coords.y, cell)}"
        },
        {
          "name": "end_data",
          "init": {},
          "expr": "{x: iscale('x', end_coords.x, cell), y: iscale('y', end_coords.y, cell)}"
        },
        {
          "name": "brush",
          "init": {"x1": 0, "y1": 0, "x2": 0, "y2": 0},
          "streams": [{
            "type": "start_coords, end_coords",
            "expr": "{x1: cell.x + start_coords.x, y1: cell.y + start_coords.y, x2: cell.x + end_coords.x, y2: cell.y + end_coords.y}"
          }]
        }
      ],
      "scales": [
        {
          "name": "gx",
          "type": "ordinal",
          "range": "width",
          "round": true,
          "domain": {"data": "fields", "field": "data"}
        },
        {
          "name": "gy",
          "type": "ordinal",
          "range": "height",
          "round": true,
          "reverse": true,
          "domain": {"data": "fields", "field": "data"}
        },
        {
          "name": "c",
          "type": "ordinal",
          "domain": {
            "data": "iris",
            "field": ordinal
          },
          "range": "category10"
        }
      ],
      "legends": [
        {
          "fill": "c",
          "title": ordinal,
          "offset": 10,
          "properties": {
            "symbols": {
              "fillOpacity": {"value": 0.5},
              "stroke": {"value": "transparent"}
            }
          }
        }
      ],
      "marks": [
        {
          "name": "cell",
          "type": "group",
          "from": {
            "data": "fields",
            "transform": [{"type": "cross"}]
          },
          "properties": {
            "enter": {
              "a": {"field": "a.data"},
              "b": {"field": "b.data"},
              "x": {"scale": "gx", "field": "a.data"},
              "y": {"scale": "gy", "field": "b.data"},
              "width": {"scale": "gx", "band": true, "offset":-35},
              "height": {"scale": "gy", "band": true, "offset":-35},
              "fill": {"value": "#fff"},
              "stroke": {"value": "#ddd"}
            }
          },
          "scales": [
            {
              "name": "x",
              "type": "linear",
              "domain": {"data": "iris", "field": {"parent": "a.data"}},
              "range": "width",
              "zero": false,
              "round": true
            },
            {
              "name": "y",
              "type": "linear",
              "domain": {"data": "iris", "field": {"parent": "b.data"}},
              "range": "height",
              "zero": false,
              "round": true
            }
          ],
          "axes": [
            {
              "type": "x",
              "scale": "x",
              "ticks": 5,
              "labels": {
                "interactive": true,
              }
            },
            {"type": "y", "scale": "y", "ticks": 5}
          ],
          "marks": [
            {
              "name": mark,
              "type": "symbol",
              "from": {"data": "iris"},
              "properties": {
                "enter": {
                  "x": {"scale": "x", "field": {"datum": {"parent": "a.data"}}},
                  "y": {"scale": "y", "field": {"datum": {"parent": "b.data"}}},
                  "fill": {"scale": "c", "field": ordinal},
                  "fillOpacity": {"value": 0.5},
                  "size": {"value": 36}
                },
                "update": {
                  "fill": [
                    {
                      "test": "inrange(datum[cell.a], start_data.x, end_data.x) && inrange(datum[cell.b], start_data.y, end_data.y)",
                      "scale": "c",
                      "field": ordinal
                    },
                    {"value": "grey"}
                  ]
                }
              }
            }
          ]
        }
      ,
        {
          "type": "rect",
          "properties": {
            "enter": {
              "fill": {"value": "grey"},
              "fillOpacity": {"value": 0.2}
            },
            "update": {
              "x":  {"signal": "brush.x1"},
              "y":  {"signal": "brush.y1"},
              "x2": {"signal": "brush.x2"},
              "y2": {"signal": "brush.y2"}
            }
          }
        }
      ]
    }

    @ve '#vis', vSpec, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
      return
