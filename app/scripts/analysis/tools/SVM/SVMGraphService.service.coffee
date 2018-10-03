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
    @svm = require 'ml-svm'

  mesh_grid_point: (coordinates, classes, type,legend) ->
    # append the mesh_grid point into the vega-lite graph
    if type == "mesh"
        value = []
        count = 0
        for single in coordinates
          new_dict = {}
          new_dict["cx-c"] = single[0]
          new_dict["cy-c"] = single[1]
          if classes[count] == 1
            new_dict["class"] = legend[1]
          else if classes[count] == -1
            new_dict["class"] = legend[-1]
          value.push new_dict
          count += 1
        return value
    else if type == "train"
        value = []
        count = 0
        for single in coordinates
          new_dict = {}
          new_dict["x-c"] = single[0]
          new_dict["y-c"] = single[1]
          if classes[count] == 1
            new_dict["class"] = "1"
          else if classes[count] == -1
            new_dict["class"] = "-1"
          value.push new_dict
          count += 1
        return value

  scatter_point: (coordinates,classes) ->
    value = []
    count = 0
    for single in coordinates
      new_dict = {}
      new_dict["x-c"] = single[0]
      new_dict["y-c"] = single[1]
      if classes.length != 0
      	if classes[count] == 1
      		new_dict["class"] = "1"
      	else if classes[count] == -1
      		new_dict["class"] = "-1"
      count += 1
      value.push new_dict
    return value



  drawSVM: (data) ->

    vSpec = {}

    if data.state is "scatter"
 
      values = @scatter_point(data.coords,data.labels)
      vSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.0.json",
        "width": 400,
        "height": 400, 
        "data": {
          "values": values
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
            }
        ] 
      }
    else if data.state is "svm"


      type = "train"
      train_values = @mesh_grid_point(data.coords, data.labels,type,data.legend)
      type = "mesh"
      mesh_grid_values = @mesh_grid_point(data.mesh_grid_points, data.mesh_grid_labels,type,data.legend)
      console.log train_values
      values = train_values
      values = values.concat mesh_grid_values
      #use predication mesh_grid to show the decision boundary
      
      vSpec = {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.0.json",
        "width": 400,
        "height": 400, 
        "data": {
          "values": values
        },
        "layer":[
            {
            "mark": {"type": "point", "filled": true, "opacity": 0.5, "fillOpacity": 0.5},
            "encoding": {
            "x": {"field": "cx-c","type": "quantitative"},
            "y": {"field": "cy-c","type": "quantitative"},
            "color": {"field": "class", "type": "nominal"}
            "tooltip": {"field": "class", "type": "ordinal"}
            }
            },
            {
            "mark": {"type": "point", "filled": true, "opacity": 1, "size": 60},
            "encoding": {
            "x": {"field": "x-c","type": "quantitative"},
            "y": {"field": "y-c","type": "quantitative"},
            "color": {"field": "class", "type": "nominal"}
            "tooltip": {"field": "class", "type": "ordinal"}
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

