'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsAreaChart extends BaseService
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

  drawArea: (data, labels, container) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    vlSpec = {
      # Properties for top-level specification (e.g., standalone single view specifications)
      "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
      
      # Properties for any specifications
      "data": {"values": data},

      # Properties for any single view specifications
      "width": 500,
      "height": 500,
      "mark": { "type": "area", "tooltip": null },
      "encoding": {
        "x": {
          "field": labels.xLab.value, "type": "temporal", "axis": {"title": labels.xLab.value}
        },
        "y": {
          "field": labels.yLab.value, "type": "quantitative", "axis": {"title": labels.yLab.value}
        }
      }
    }

    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )
