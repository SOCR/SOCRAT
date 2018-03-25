'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class SVMGraph extends BaseService
  @inject '$q',
    '$stateParams',
    'app_analysis_svm_dataService',
    'app_analysis_svm_msgService'
    

  initialize: ->

    @msgService = @app_analysis_svm_msgService
    @dataService = @app_analysis_svm_dataService
    @DATA_TYPES = @dataService.getDataTypes()
    @ve = require 'vega-embed'

  drawSVM: (data) ->
  
    vSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.0.json",
      "width": 400,
      "height": 400, 
      "data": {
        "values": [
          {"x-c": 5,"y-c": 28,"class":"one"}, {"x-c": 34,"y-c": 55,"class":"two"}, {"x-c": 45,"y-c": 43,"class":"two"},
          {"x-c": 5,"y-c": 91,"class":"two"}, {"x-c": 13,"y-c": 81,"class":"two"}, {"x-c": 56,"y-c": 53,"class":"two"},
          {"x-c": 15,"y-c": 19,"class":"one"}, {"x-c": 15,"y-c": 87,"class":"two"}, {"x-c": 13,"y-c": 52,"class":"one"},
          {"x-l": 0,"y-l": 100},{"x-l": 60,"y-l": 0}
        ]
      },
      "layer":[
          {
          "mark": {"type": "point", "filled": true},
          "encoding": {
          "x": {"field": "x-c","type": "quantitative"},
          "y": {"field": "y-c","type": "quantitative"},
          "color": {"field": "class", "type": "nominal"}
          "tooltip": {"field": "class", "type": "ordinal"}
          }
          },  
          {
          "mark":"line",
          "encoding":{
          "x": {"field": "x-l","type": "quantitative"},
          "y": {"field": "y-l","type": "quantitative"}
          }
          }
        ]
    }
    opt =
      "actions": {export: true, source: false, editor: false}

    @ve '#vis', vSpec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
      return

