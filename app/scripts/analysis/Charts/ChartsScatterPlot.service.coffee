'use strict'

require 'vega-tooltip/build/vega-tooltip.css'
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

  drawScatterPlot: (data,labels) ->

    console.log(labels)

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "width": 500,
      "height": 500,
      "data": {"values": data},
      "selection": {
        "grid": {
          "type": "interval", "bind": "scales"
        }
      },
      "mark": "circle",
      "encoding": {
        "x": {
          "field": labels.xLab.value, "type": "quantitative", "axis": {"title": labels.xLab.value}
        },
        "y": {
          "field": labels.yLab.value, "type": "quantitative", "axis": {"title": labels.yLab.value}
        }
      }
    }

#    if labels["zLab"].value
#      vlSpec.encoding.color.field = labels.zLab.value
#      vlSpec.encoding.color.type = "nominal"

    opt = {mode: "vega-lite", "actions": {export: true, source: false, editor: true}}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )
