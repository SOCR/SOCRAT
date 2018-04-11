'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_svm_csvc
  @desc: Performs SVM classification (C formulation)
###

module.exports = class SVMCSVC extends BaseService
  @inject '$timeout', 'app_analysis_svm_metrics'

  initialize: () ->
    @metrics = @app_analysis_svm_metrics
    @jsfeat = require 'jsfeat'
    @svm = require 'ml-svm'

    @name = 'C-SVC'
    exponents = [-4..5]
    @cs = (Math.pow 10,num for num in exponents)
    @lables = null

    #runtime variables
    @svmModel = null
    @features = null
    @labels = null

    # Variables for Graphing Service
    @mesh_grid_points = null
    @mesh_grid_label = null
    # features / labels


    # module hyperparameters
    @params =
      c: @cs
      kernel: @metrics.getKernelNames()

  getName: -> @name
  getParams: -> @params

  saveData: (data) ->
    @features = data.features
    @labels = data.labels

  train: (data) ->
    @svmModel.train(@features, @labels);
    return @updateGraphData()

  setParams: (newParams) ->
    @params = newParams
    options =
      C: newParams.c
      tol: 10e-4
      maxPasses: 10
      maxIterations: 10000
      kernel: newParams.kernel
      kernelOptions: sigma: 0.5
    @svmModel = new @svm options
    return

  updateGraphData: ->
    #return the mesh_grid and training data for graphing service
    min_max = @get_boundary_from_feature()
    @mesh_grid_points = @mesh_grid_2d_init(min_max['min_x'], min_max['min_y'], 0.1)
    @mesh_grid_label = @mesh_grid_predict_label(@svmModel, @mesh_grid_points)
    result =
      mesh_grid_points: @mesh_grid_points
      mesh_grid_labels: @mesh_grid_label
      features: @features
      labels: @labels
    return result

  getUniqueLabels: (labels) -> labels.filter (x, i, a) -> i is a.indexOf x

  initLabels: (l, k) ->
    labels = []
    labels.push Math.floor(Math.random() * k) for i in [0..l]
    labels

  reset: ()->
    @done = off
    @iter = 0

  # Mesh_grid related functions
  mesh_grid_2d_init: (low_bound, high_bound, step_size) ->
    # Initialize the mesh_grid points
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

  get_boundary_from_feature: () ->
    # get minimum of x
    x_column = []
    y_column = []
    for x in @features
      x_column.push(parseFloat x[0])
      y_column.push(parseFloat x[1])

    min_x = Math.min.apply(null, x_column);
    min_y = Math.min.apply(null, y_column);
    max_x = Math.max.apply(null, x_column);
    max_y = Math.max.apply(null, y_column);
    result =
      min_x : min_x
      max_x : max_x
      min_y : min_y
      max_y : max_y
    return result

