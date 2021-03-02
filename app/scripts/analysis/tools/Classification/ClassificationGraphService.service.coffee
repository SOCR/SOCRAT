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
    @ve = require('vega-embed').default
    @svm = require 'ml-svm'

  # Function creates a mesh grid for the background and data points
  mesh_grid_point: (coordinates, classes, type,legend, xCol, yCol) ->
    # append the mesh_grid point into the vega-lite graph
    if type == "mesh"
        value = []
        count = 0
        #iterate over the coordinates and add them to the dictionary accordingly
        for single in coordinates
          new_dict = {}
          new_dict[" "] = single[0]
          new_dict["  "] = single[1]
          new_dict["class"] = legend[classes[[count]]]
          value.push new_dict
          count += 1
        return value
    else if type == "train"
        value = []
        count = 0
        #iterate over the coordinates and add them to the dictionary accordingly
        for single in coordinates
          new_dict = {}
          new_dict['' +xCol.toString()] = single[0]
          new_dict['' +yCol.toString()] = single[1]
          new_dict["class"] = legend[classes[[count]]]
          value.push new_dict
          count += 1
        return value

  #responsible for creating the scatter_plot when 2 variables are chosen in side bar
  scatter_point: (coordinates,classes, legend, xCol, yCol) ->
    value = []
    count = 0
    #iterate over the coordinates and add them to the dictionary accordingly
    for single in coordinates
      new_dict = {}
      new_dict[xCol] = single[0]
      new_dict[yCol] = single[1]
      #set the class for each data point using the legends 
      if classes.length != 0
        new_dict["class"] = legend[classes[[count]]]
      count += 1
      value.push new_dict
    return value


  #draws the actual graph using functions above and Vegalite
  drawSVM: (data) ->

    vSpec = {}
    #finding the min and max to set the range of the two axis
    minX = Infinity
    minY = Infinity
    maxX = -Infinity
    maxY = -Infinity
    for datapoint in data.coords
      if parseFloat(datapoint[0]) < minX
        minX = datapoint[0]
      if parseFloat(datapoint[0]) > maxX
        maxX = datapoint[0]

      if parseFloat(datapoint[1]) < minY
        minY = datapoint[1]
      if parseFloat(datapoint[1]) > maxY
        maxY = datapoint[1]

    if data.state is "scatter"
      #getting the values data set using scatter point function
      values = @scatter_point(data.coords,data.labels, data.legend, data.xCol, data.yCol)
      #vegalite format to create a graph
      vSpec = {

        "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
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
    else if data.state is "svm"

      #train using the data points and create a mesh grid
      type = "train"
      train_values = @mesh_grid_point(data.coords, data.labels,type,data.legend, data.xCol, data.yCol)
      type = "mesh"
      mesh_grid_values = @mesh_grid_point(data.mesh_grid_points, data.mesh_grid_labels,type,data.legend, data.xCol, data.yCol)
      values = train_values
      #concat the two data points set
      values = values.concat mesh_grid_values
      
      #vegalite format to create a graph
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
            "x": {"field": " " ,"type": "quantitative", "scale":{"domain": [minX, maxX], "type":"linear"} },
            "y": {"field": "  ","type": "quantitative", "scale":{"domain": [minY, maxY], "type":"linear"} },
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

    @ve '#vis', vSpec, opt, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
        return

