'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsTreemap extends BaseService
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
    @vt = require 'vega-tooltip/build/vega-tooltip.js'

  drawTreemap: (data, labels, container) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    vSpec = {
      "$schema": "https://vega.github.io/schema/vega/v4.json",
      "width": 960,
      "height": 500,
      "padding": 2.5,
      "autosize": "none",
      "signals": [
        {
          "name": "layout", "value": "squarify",
          "bind": {
            "input": "select",
            "options": [
              "squarify",
              "binary",
              "slicedice"
            ]
          }
        },
        {
          "name": "aspectRatio", "value": 1.6,
          "bind": {"input": "range", "min": 0.2, "max": 5, "step": 0.1}
        }
      ],

      "data": [
        {
          "name": "tree",
          "values": data,
          "transform": [
            {
              "type": "stratify",
              "key": labels.xLab.value,
              "parentKey": labels.yLab.value
            },
            {
              "type": "treemap",
              "field": labels.rLab.value,
              "sort": {"field": "value"},
              "round": true,
              "method": {"signal": "layout"},
              "ratio": {"signal": "aspectRatio"},
              "size": [{"signal": "width"}, {"signal": "height"}]
            }
          ]
        },
        {
          "name": "nodes",
          "source": "tree",
          "transform": [{ "type": "filter", "expr": "datum.children" }]
        },
        {
          "name": "leaves",
          "source": "tree",
          "transform": [{ "type": "filter", "expr": "!datum.children" }]
        }
      ],

      "scales": [
        {
          "name": "color",
          "type": "ordinal",
          "range": [
            "#3182bd", "#6baed6", "#9ecae1", "#c6dbef", "#e6550d",
            "#fd8d3c", "#fdae6b", "#fdd0a2", "#31a354", "#74c476",
            "#a1d99b", "#c7e9c0", "#756bb1", "#9e9ac8", "#bcbddc",
            "#dadaeb", "#636363", "#969696", "#bdbdbd", "#d9d9d9"
          ]
        },
        {
          "name": "size",
          "type": "ordinal",
          "domain": [0, 1, 2, 3],
          "range": [256, 28, 20, 14]
        },
        {
          "name": "opacity",
          "type": "ordinal",
          "domain": [0, 1, 2, 3],
          "range": [0.15, 0.5, 0.8, 1.0]
        }
      ],

      "marks": [
        {
          "type": "rect",
          "from": {"data": "nodes"},
          "interactive": false,
          "encode": {
            "enter": {
              "fill": {"scale": "color", "field": labels.zLab.value}
            },
            "update": {
              "x": {"field": "x0"},
              "y": {"field": "y0"},
              "x2": {"field": "x1"},
              "y2": {"field": "y1"}
            }
          }
        },
        {
          "type": "rect",
          "from": {"data": "leaves"},
          "encode": {
            "enter": {
              "stroke": {"value": "#fff"}
            },
            "update": {
              "x": {"field": "x0"},
              "y": {"field": "y0"},
              "x2": {"field": "x1"},
              "y2": {"field": "y1"},
              "fill": {"value": "transparent"}
            },
            "hover": {
              "fill": {"value": "red"}
            }
          }
        },
        {
          "type": "text",
          "from": {"data": "nodes"},
          "interactive": false,
          "encode": {
            "enter": {
              "font": {"value": "Helvetica Neue, Arial"},
              "align": {"value": "center"},
              "baseline": {"value": "middle"},
              "fill": {"value": "#000"},
              "text": {"field": "name"},
              "fontSize": {"scale": "size", "field": "depth"},
              "fillOpacity": {"scale": "opacity", "field": "depth"}
            },
            "update": {
              "x": {"signal": "0.5 * (datum.x0 + datum.x1)"},
              "y": {"signal": "0.5 * (datum.y0 + datum.y1)"}
            }
          }
        }
      ]
    }


    opt =
      "actions": {export: true, source: false, editor: false}

    @ve('#vis', vSpec, opt, (error, result) -> return).then((result) =>
      @vt.vega(result.view)
    )
