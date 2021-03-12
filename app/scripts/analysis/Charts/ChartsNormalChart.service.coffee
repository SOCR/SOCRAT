'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsNormalChart extends BaseService
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
    @scatterPlot = @app_analysis_charts_scatterPlot

    @DATA_TYPES = @dataService.getDataTypes()
    @ve = @list.getVegaEmbed()
    @vt = @list.getVegaTooltip()
    @schema = @list.getVegaSchema()

  drawNormalCurve: (data, labels, container, flags) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    x_ = labels.xLab.value

    sumx = 0
    sumy = 0
    for dic in data
      sumx += parseFloat(dic[x_])

    mean_x = sumx/data.length

    for dic in data
      dic["residual_x"] = dic[x_] - mean_x

    if (flags.x_residual)
      labels.xLab.value = "residual_x"

    vSpec = {
      "$schema": @schema,
      "width": 300,
      "height": 300,
      "padding": 5,
      "signals": [
        {
          "name": "bandwidth",
          "value": 0,
          "bind": {
            "input": "range",
            "min": 0,
            "max": 0.1,
            "step": 0.001
          }
        },
        {
          "name": "steps",
          "value": 100,
          "bind": {
            "input": "range",
            "min": 10,
            "max": 500,
            "step": 1
          }
        },
        {
          "name": "method",
          "value": "pdf",
          "bind": {
            "input": "radio",
            "options": [
              "pdf",
              "cdf"
            ]
          }
        }
      ],
      "data": [
        {
          "name": "points",
          "values": data
        },
        {
          "name": "summary",
          "source": "points",
          "transform": [
            {
              "type": "aggregate",
              "fields": [
                labels.xLab.value,
                labels.xLab.value
              ],
              "ops": [
                "mean",
                "stdev"
              ],
              "as": [
                "mean",
                "stdev"
              ]
            }
          ]
        },
        {
          "name": "density",
          "source": "points",
          "transform": [
            {
              "type": "density",
              "extent": {
                "signal": "domain('xscale')"
              },
              "steps": {
                "signal": "steps"
              },
              "method": {
                "signal": "method"
              },
              "distribution": {
                "function": "kde",
                "field": labels.xLab.value,
                "bandwidth": {
                  "signal": "bandwidth"
                }
              }
            }
          ]
        },
        {
          "name": "normal",
          "transform": [
            {
              "type": "density",
              "extent": {
                "signal": "domain('xscale')"
              },
              "steps": {
                "signal": "steps"
              },
              "method": {
                "signal": "method"
              },
              "distribution": {
                "function": "normal",
                "mean": {
                  "signal": "data('summary')[0].mean"
                },
                "stdev": {
                  "signal": "data('summary')[0].stdev"
                }
              }
            }
          ]
        }
      ],
      "scales": [
        {
          "name": "xscale",
          "type": "linear",
          "range": "width",
          "domain": {
            "data": "points",
            "field": labels.xLab.value
          },
          "nice": true
        },
        {
          "name": "yscale",
          "type": "linear",
          "range": "height",
          "round": true,
          "domain": {
            "fields": [
              {
                "data": "density",
                "field": "density"
              },
              {
                "data": "normal",
                "field": "density"
              }
            ]
          }
        },
        {
          "name": "color",
          "type": "ordinal",
          "domain": [
            "Normal Estimate",
            "Kernel Density Estimate"
          ],
          "range": [
            "#444",
            "steelblue"
          ]
        }
      ],
      "axes": [
        {
          "orient": "bottom",
          "scale": "xscale",
          "zindex": 1
        }
      ],
      "legends": [
        {
          "orient": "top-left",
          "fill": "color",
          "offset": 0,
          "zindex": 1
        }
      ],
      "marks": [
        {
          "type": "area",
          "from": {"data": "density"},
          "encode": {
            "update": {
              "x": {"scale": "xscale", "field": "value"},
              "y": {"scale": "yscale", "field": "density"},
              "y2": {"scale": "yscale", "value": 0},
              "fill": {"signal": "scale('color', 'Kernel Density Estimate')"}
            },
            "enter": {
              "tooltip": {"signal": "datum"}
            }
          }
        },
        {
          "type": "line",
          "from": {"data": "normal"},
          "encode": {
            "update": {
              "x": {"scale": "xscale", "field": "value"},
              "y": {"scale": "yscale", "field": "density"},
              "stroke": {"signal": "scale('color', 'Normal Estimate')"},
              "strokeWidth": {"value": 2}
            },
            "enter": {
              "tooltip": {"signal": "datum"}
            }
          }
        },
        {
          "type": "rect",
          "from": {"data": "points"},
          "encode": {
            "enter": {
              "x": {"scale": "xscale", "field": "Sepal_Length"},
              "width": {"value": 1},
              "y": {"value": 25, "offset": {"signal": "height"}},
              "height": {"value": 5},
              "fill": {"value": "steelblue"},
              "fillOpacity": {"value": 0.4}
            }
          }
        }
      ]
    }

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve('#vis', vSpec, opt, (error, result) -> return).then((result) =>
      # @vt.vega(result.view)
    )
