'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsStackedBar extends BaseService
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
    @vt = require 'vega-tooltip'

  stackedBar: (data, labels, container) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "width": 500,
      "height": 500,
      "data": {"values": data},
      "mark": "bar",
      "encoding": {
        "x": {
          "field": labels.xLab.value,
          "type": "ordinal",
          "axis":
            "title": labels.xLab.value
            # "titleFontSize": 20
            # "labelFontSize": 20
        },
        "y": {
          "aggregate": "count",
          "type": "quantitative",
          # "axis":
          #   "titleFontSize": 20
          #   "labelFontSize": 20
        }
      }
    }

    if labels["zLab"].value and labels["zLab"].value isnt "None"
      z_num_unique = (dict[labels["zLab"].value] for dict in data).filter((v, i, a) => a.indexOf(v) == i)
      color_scheme = if z_num_unique > 10 then "category20" else "category10"
      vlSpec["encoding"]["color"] =
        "field": labels.zLab.value
        "type": "nominal"
        "scale": {"scheme": color_scheme}
        "legend":
          "title": labels.zLab.value
          # "labelFontSize": 20

    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )
