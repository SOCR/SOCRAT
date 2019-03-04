'use strict'

require 'vega-tooltip/build/vega-tooltip.css'
BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsCumulativeFrequency extends BaseService
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

  drawCumulativeFrequency: (data, labels, container, flags) ->

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
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "width": 500,
      "height": 500,
      "data": {"values": data},
      "transform": [{
        "sort": [{"field": labels.xLab.value}],
        "window": [{"op": "count", "field": "count", "as": "cumulative_count"}],
        "frame": [null, 0]
      }],
      "mark": "area",
      "encoding": {
        "x": {
          "field": labels.xLab.value,
          "type": "quantitative"
        },
        "y": {
          "field": "cumulative_count",
          "type": "quantitative"
          "title": "Cumulative Count"
        }
      }
    }

    opt = {mode: "vega-lite", "actions": {export: true, source: false, editor: false}}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )

