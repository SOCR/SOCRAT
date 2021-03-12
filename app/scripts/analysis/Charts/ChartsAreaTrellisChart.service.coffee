'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsAreaTrellisChart extends BaseService
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
    @ve = @list.getVegaEmbed()
    @vt = @list.getVegaTooltip()
    @schema = @list.getVegaLiteSchema()

  areaTrellisChart: (data, labels, container) ->
    # parse the year if date is in the forme of YYYYMMDD
    if data[0][labels.xLab.value].length == 8
      for datum in data
        datum[labels.xLab.value] = datum[labels.xLab.value].substr(0, 4)

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    vlSpec = {
      "$schema": @schema,
      "width": 500,
      "height": 500,
      "data": {"values": data},
      "mark": { "type": "line" },
      "encoding": {
        "x": {"field": labels.xLab.value, "type": "temporal", "axis": {"title": labels.xLab.value}},
        "y": {"field": labels.yLab.value, "type": "quantitative", "axis": {"title": labels.yLab.value}}
      }
    }

    if labels["zLab"]?.value?
      vlSpec["encoding"]["color"] = {"field": labels.zLab.value, "type": "nominal", "legend": null}
      vlSpec["encoding"]["row"] = {"field": "labels.zLab.value", "type": "nominal", "header": {"title": "labels.zLab.value"}
      }

    handler = new @vt.Handler()
    opt =
      "actions": {export: true, source: false, editor: false}
      "tooltip": handler.call

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
    )
