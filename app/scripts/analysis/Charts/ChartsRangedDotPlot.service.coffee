'use strict'

require 'vega-tooltip'
BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsRangedDotPlot extends BaseService
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
    @ve = @list.getVegaEmbed()
    @vt = @list.getVegaTooltip()
    @schema = @list.getVegaLiteSchema()

  drawRangedDotPlot: (data, labels, container, flags) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    x_ = labels.xLab.value

    sumx = 0
    for dic in data
      sumx += parseFloat(dic[x_])

    mean_x = sumx/data.length

    for dic in data
      dic["residual_x"] = dic[x_] - mean_x

    if (flags.x_residual)
      labels.xLab.value = "residual_x"

    vlSpec = {
      "$schema": @schema,
      "data": {"values": data},
      "encoding": {
        "x": {
          "field": labels.xLab.value,
          "type": "quantitative",
          "axis": {
            "title": labels.xLab.value
          }
        },
        "y": {
          "field": labels.yLab.value,
          "type": "nominal",
          "axis": {
            "title": labels.yLab.value,
            "offset": 5,
            "ticks": false,
            "minExtent": 70,
            "domain": false
          }
        }
      },
      "layer": [
        {
          "selection": {
            "grid": {
              "type": "interval", "bind": "scales"
            }
          },
          "mark": "line",
          "encoding": {
            "detail": {
              "field": labels.yLab.value,
              "type": "nominal"
            },
            "color": {"value": "#db646f"}
          }
        },
        {
          "mark": {
            "type": "point",
            "filled": true
          },
          "encoding": {
            "size": {"value": 100},
            "opacity": {"value": 1}
          }
        }
      ]
    }

    if labels["zLab"].value and labels["zLab"].value isnt "None"
      vlSpec["layer"][1]["encoding"]["color"] =
        "field": labels.zLab.value,
        "type": "nominal",
        "scale": {"scheme": "category20b"}

    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )
