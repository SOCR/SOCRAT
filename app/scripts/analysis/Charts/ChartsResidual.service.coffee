'use strict'

require 'vega-tooltip'
BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsResidual extends BaseService
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
    @vt = require 'vega-tooltip'

  drawResidual: (data, labels, container) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "width": 500,
      "height": 500,
      "data": {"values": data},
      "transform": [
        {
          "window": [{
            "op": "mean",
            "field": labels.yLab.value,
            "as": "AverageRating"
          }],
          "frame": [null, null]
        },
        {
          "calculate": "datum.#{labels.yLab.value} - datum.AverageRating",
          "as": "RatingDelta"
        }
      ],
      "mark": "point",
      "encoding": {
        "x": {
          "field": labels.xLab.value,
          "type": "quantitative",
          "axis": {"title": labels.xLab.value}
        },
        "y": {
          "field": "RatingDelta",
          "type": "quantitative",
          "axis": {"title": "Rating Delta"}
        }
      }
    }

    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )
