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
    @scatterPlot = @app_analysis_charts_scatterPlot

    @DATA_TYPES = @dataService.getDataTypes()
    @ve = @list.getVegaEmbed()
    @vt = @list.getVegaTooltip()
    @schema = @list.getVegaLiteSchema()

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
    datavals = {}
    datavals["values"] = []
    count = 1
    group = 1
    for row, row_ind in d
      for field, field_ind in fields
        inner = {}
        inner["morphology"] = d[row_ind][field]
        inner["groups"] = group
        inner["vars"] = field
        inner["species"] = d[row_ind][ordinal]
        datavals["values"].push inner
        count = count + 1
        if d.length + fields.length > (150 * 4)
          if count > parseInt((d.length + fields.length)/150, 10)
            group = group + 1
            count = 1
        else
          if count == 4
            group = group + 1
            count = 1
    console.log(datavals)
    
    v1Spec = {
      "$schema": @schema,
      "config": {"view": {"stroke": ""}},
      "data": datavals
      "layer": [{
        "width": 600,
        "height": 300,
        "mark": {"type": "line", "strokeWidth": 0.3},
        "encoding": {
          "x": {
            "field": "vars",
            "type": "ordinal",
            "axis": {"domain": false, "grid": false}
          },
          "y": {"field": "morphology", "type": "quantitative"},
          "detail": {"field": "groups", "type": "nominal"}, 
          "color": {
            "field": "species",
            "type": "nominal",
            "scale": {
              "domain": labels
              }
            }
          }
        },
        {
          "width": 600, 
          "mark": "rule",
          "encoding": {
            "x": {"field": "vars", "type": "ordinal", "axis": {"title": ""}}
          }
        }
      ]
    }
    
    opt =
      "actions": {export: true, source: false, editor: false}

    @ve '#vis', v1Spec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
      return
