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


  mesh_grid_2d_init: (low_bound, high_bound, step_size) ->
    grid_array = []
    if low_bound >= high_bound
      return []
    i = low_bound
    while i < high_bound
      j = low_bound
      while j < high_bound
        grid_element = [i, j]
        grid_array.push grid_element
        j += step_size
      i += step_size
    return grid_array

  mesh_grid_predict_label: (svmModel, mesh_grid) ->
    # return the mesh_grid with the prediction label
    pred = svmModel.predict(mesh_grid)
    return pred

  mesh_grid_point: (coordinates, classes, type) ->
    # append the mesh_grid point into the vega-lite graph
    if type == "mesh"
        value = []
        count = 0
        for single in coordinates
          new_dict = {}
          new_dict["cx-c"] = single[0]
          new_dict["cy-c"] = single[1]
          if classes[count] == 1
            new_dict["class"] = "class_one"
          else if classes[count] == -1
            new_dict["class"] = "class_two"
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
            new_dict["class"] = "one"
          else if classes[count] == -1
            new_dict["class"] = "two"
          value.push new_dict
          count += 1
        return value






  drawSVM: (data) ->
    options =
      C: 0.01
      tol: 10e-4
      maxPasses: 10
      maxIterations: 10000
      kernel: 'linear'
      kernelOptions: sigma: 0.5

    svmModel = new @svm options
    #xor example
    features = [[1,1],[2,2],[2,3],[4,4],[-1,-1],[-2,-2],[-3,-3],[-4,-4]]
    labels = [1, 1, 1, 1, -1, -1, -1, -1]
    svmModel.train(features, labels);
    console.log svmModel.predict features
    console.log svmModel.margin features
    svmJson = svmModel.toJSON()
    supportVectorId = svmModel.supportVectors();
    mesh_grid = @mesh_grid_2d_init(-4, 4, 0.1)
    pred_mesh_grid = @mesh_grid_predict_label(svmModel, mesh_grid)
    type = "train"
    train_values = @mesh_grid_point(features, labels,type)
    type = "mesh"
    mesh_grid_values = @mesh_grid_point(mesh_grid, pred_mesh_grid,type)
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

