'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ClassificationGraph extends BaseService
  @inject '$q',
    '$stateParams',
    'app_analysis_classification_dataService',
    'app_analysis_classification_msgService'


  initialize: ->

    @msgService = @app_analysis_classification_msgService
    @dataService = @app_analysis_classification_dataService
    @DATA_TYPES = @dataService.getDataTypes()
    @ve = require 'vega-embed'
    @svm = require 'ml-svm'

  mesh_grid_point: (coordinates, classes, type,legend, xCol, yCol) ->
    # append the mesh_grid point into the vega-lite graph
    if type == "mesh"
        value = []
        count = 0
        for single in coordinates
          new_dict = {}
          new_dict['' + xCol.toString() + "_"] = single[0]
          new_dict['' +yCol.toString() + "_"] = single[1]

          new_dict["class"] = legend[classes[[count]]]

          # if classes[count] == 1
          #   new_dict["class"] = legend[1]
          # else if classes[count] == -1
          #   new_dict["class"] = legend[-1]
          value.push new_dict
          count += 1
        return value
    else if type == "train"
        value = []
        count = 0
        for single in coordinates
          new_dict = {}
          new_dict['' +xCol.toString()] = single[0]
          new_dict['' +yCol.toString()] = single[1]
          new_dict["class"] = legend[classes[[count]]]

          # if classes[count] == 1
          #   new_dict["class"] = legend[1]
          # else if classes[count] == -1
          #   new_dict["class"] = legend[-1]
          value.push new_dict
          count += 1
        return value

  scatter_point: (coordinates,classes, legend, xCol, yCol) ->
    value = []
    count = 0
    for single in coordinates
      new_dict = {}
      new_dict[xCol] = single[0]
      new_dict[yCol] = single[1]
      # new_dict["x-col"] = single[0]
      # new_dict["y-col"] = single[1]
      if classes.length != 0
        new_dict["class"] = legend[classes[[count]]]
      	# if classes[count] == 1
      	# 	new_dict["class"] = legend[1]
      	# else if classes[count] == -1
      	# 	new_dict["class"] = legend[-1]
      count += 1
      value.push new_dict
    return value



  drawSVM: (data) ->

    vSpec = {}

    minX = Infinity
    minY = Infinity
    maxX = -Infinity
    maxY = -Infinity
    for datapoint in data.coords
      if datapoint[0] < minX
        minX = datapoint[0]
      if datapoint[1] < minY
        minY = datapoint[1]
      if datapoint[0] > maxX
        maxX = datapoint[0]
      if datapoint[1] > maxY
        maxY = datapoint[1]

    if data.state is "scatter"

      values = @scatter_point(data.coords,data.labels, data.legend, data.xCol, data.yCol)
      vSpec = {

        "$schema": "https://vega.github.io/schema/vega-lite/v2.0.json",
        "width": 400,
        "height": 400,
        "data": {
          "values": values

        },
        "layer":[
            {
            "mark": {"type": "point", "filled": true, "size": 75},
            "encoding": {
            "x": {"field": data.xCol.toString(),"type": "quantitative","scale":{"domain": [minX, maxX], "type":"linear"} },
            "y": {"field": data.yCol.toString(),"type": "quantitative","scale":{"domain": [minY, maxY], "type":"linear"} },
            "color": {"field": "class", "type": "nominal"}
            "tooltip": {"field": "class", "type": "ordinal"}
            }
            }
        ]
      }
      console.log vSpec
    else if data.state is "svm"


      type = "train"
      train_values = @mesh_grid_point(data.coords, data.labels,type,data.legend, data.xCol, data.yCol)
      type = "mesh"
      mesh_grid_values = @mesh_grid_point(data.mesh_grid_points, data.mesh_grid_labels,type,data.legend, data.xCol, data.yCol)
      console.log train_values
      values = train_values
      values = values.concat mesh_grid_values
      console.log 'mesh-grid values'
      console.log mesh_grid_values
      #use predication mesh_grid to show the decision boundary

      vSpec = {

        "$schema": "https://vega.github.io/schema/vega-lite/v2.0.json",
        "width": 400,
        "height": 400,
        "data": {
          "values": values,

        },
        "layer":[
            {
            "mark": {"type": "point", "filled": true, "opacity": 0.5, "fillOpacity": 0.5},
            "encoding": {
            "x": {"field": '' +data.xCol.toString() + "_" ,"type": "quantitative", "scale":{"domain": [minX, maxX], "type":"linear"} },
            "y": {"field": '' +data.yCol.toString() + "_","type": "quantitative", "scale":{"domain": [minY, maxY], "type":"linear"} },
            "color": {"field": "class", "type": "nominal"}
            "tooltip": {"field": "class", "type": "ordinal"}
            }
            },
            {
            "mark": {"type": "point", "filled": true, "opacity": 1, "size": 75},
            "encoding": {
            "x": {"field": '' +data.xCol.toString(),"type": "quantitative", "scale":{"domain": [minX, maxX], "type":"linear" } },
            "y": {"field": '' +data.yCol.toString(),"type": "quantitative", "scale":{"domain": [minY, maxY], "type":"linear" } },
            "color": {"field": "class", "type": "nominal"}
            "tooltip": {"field": "class", "type": "ordinal"}
            }
            }
          ],

      }

    opt =
      "actions": {export: true, source: false, editor: false}

    console.log vSpec

    @ve '#vis', vSpec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
        return

