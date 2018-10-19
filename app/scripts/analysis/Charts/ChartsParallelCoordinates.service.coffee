'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsParallel extends BaseService
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

  drawParallel: (data, width, height, _graph, labels, container) ->

    fields = data.splice(0, 1)[0]
    if labels
      ordinal = labels.splice(0, 1)[0]

    d = []
    for row, row_ind in data
      row_obj = {}
      for label, lbl_idx in fields
        row_obj[label] = row[lbl_idx]
      if labels
        row_obj[ordinal] = labels[row_ind]
      d.push row_obj

    dataobj = []
    vals = {}
    vals["name"] = "cars"
    vals["values"] = d
    dataobj.push vals
    vals = {}
    vals["name"] = "fields"
    vals["values"] = fields
    dataobj.push vals

    console.log(dataobj)

    axesobj = []
    for row, row_ind in fields
      inner = {}
      inner["orient"] = "left"
      inner["zindex"] = 1
      inner["scale"] = row
      inner["title"] = row
      offsetval = {}
      offsetval["scale"] = "ord"
      offsetval["value"] = row
      offsetval["mult"] = -1
      inner["offset"] = offsetval
      axesobj.push inner

    scalesobj = []
    inner = {}
    inner["name"] = "ord"
    inner["type"] = "point"
    inner["range"] = "width"
    inner["round"] = true
    domainval = {}
    domainval["data"] = "fields"
    domainval["field"] = "data"
    inner["domain"] = domainval
    scalesobj.push inner
    for row, row_ind in fields
      inner = {}
      inner["name"] = row
      inner["type"] = "linear"
      inner["range"] = "height"
      inner["zero"] = false
      inner["nice"] = true
      domainval = {}
      domainval["data"] = "cars"
      domainval["field"] = row
      inner["domain"] = domainval
      scalesobj.push inner

    v1Spec = {
      "$schema": "https://vega.github.io/schema/vega/v4.json",
      "width": 700,
      "height": 400,
      "padding": 5,

      "config": {
        "axisY": {
          "titleX": -2,
          "titleY": 410,
          "titleAngle": 0,
          "titleAlign": "right",
          "titleBaseline": "top"
        }
      },
      "data": dataobj
      "scales": scalesobj
      "axes": axesobj

      "marks": [
        {
          "type": "group",
          "from": {"data": "cars"},
          "marks": [
            {
              "type": "line",
              "from": {"data": "fields"},
              "encode": {
                "enter": {
                  "x": {"scale": "ord", "field": "data"},
                  "y": {
                    "scale": {"datum": "data"},
                    "field": {"parent": {"datum": "data"}}
                  },
                  "stroke": {"value": "steelblue"},
                  "strokeWidth": {"value": 1.01},
                  "strokeOpacity": {"value": 0.3}
                }
              }
            }
          ]
        }
      ]
    }

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve '#vis', v1Spec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
      return
