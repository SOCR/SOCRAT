'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsPieChart extends BaseService
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

  drawPie: (data, labels, container, flags) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    sort = true
    field = labels.xLab.value
    if flags.categorical
      sort = false
      field = flags.col
    console.log(sort)
    vSpec = {
      "$schema": "https://vega.github.io/schema/vega/v4.json",
      "width": 300,
      "height": 300,
      "autosize": "none",

      "signals": [
        {
          "name": "startAngle", "value": 0,
          "bind": {"input": "range", "min": 0, "max": 6.29, "step": 0.01}
        },
        {
          "name": "endAngle", "value": 6.29,
          "bind": {"input": "range", "min": 0, "max": 6.29, "step": 0.01}
        },
        {
          "name": "padAngle", "value": 0,
          "bind": {"input": "range", "min": 0, "max": 0.1}
        },
        {
          "name": "innerRadius", "value": 0,
          "bind": {"input": "range", "min": 0, "max": 150, "step": 10}
        },
        {
          "name": "cornerRadius", "value": 0,
          "bind": {"input": "range", "min": 0, "max": 10, "step": 0.5}
        },
        {
          "name": "sort", "value": sort,
          "bind": {"input": "checkbox"}
        }
      ],

      "data": [
        {
          "name": "table",
          "values": data,
          "transform": [
            {
              "type": "pie",
              "field": field,
              "startAngle": {"signal": "startAngle"},
              "endAngle": {"signal": "endAngle"},
              "sort": {"signal": "sort"}
            }
          ]
        }
      ],

      "scales": [
        {
          "name": "color",
          "type": "ordinal",
          "range": {"scheme": "category20"}
        }
      ],

      "marks": [
        {
          "type": "arc",
          "from": {"data": "table"},
          "encode": {
            "enter": {
              "fill": {"scale": "color", "field": labels.xLab.value},
              "x": {"signal": "width / 2"},
              "y": {"signal": "height / 2"}
            },
            "update": {
              "startAngle": {"field": "startAngle"},
              "endAngle": {"field": "endAngle"},
              "padAngle": {"signal": "padAngle"},
              "innerRadius": {"signal": "innerRadius"},
              "outerRadius": {"signal": "width / 2"},
              "cornerRadius": {"signal": "cornerRadius"}
            }
          }
        }
      ]
    }

    opt =
      "actions": {export: true, source: false, editor: true}

    @ve('#vis', vSpec, opt, (error, result) -> return).then((result) =>
      @vt.vega(result.view)
    )
