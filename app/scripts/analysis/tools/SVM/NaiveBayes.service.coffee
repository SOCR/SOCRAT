'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_svm_csvc
  @desc: Performs SVM classification (C formulation)
###

module.exports = class NaiveBayes extends BaseService
  @inject '$timeout', 'app_analysis_svm_metrics'

  initialize: () ->
    @metrics = @app_analysis_svm_metrics
    @jsfeat = require 'jsfeat'

    @bayes = require 'ml-naivebayes'

    @name = 'NaiveBayes'

    @options = null
    @lables = null

    #runtime variables
    @model = null
    @features = null
    @labels = null

    # Variables for Graphing Service
    @mesh_grid_points = null
    @mesh_grid_label = []
    # features / labels

    # module hyperparameters
    @params = null

  getName: -> @name
  getParams: -> @params

  saveData: (data) ->
    @features = data.features
    @labels = data.labels

  train: (data) ->
    console.log "features"
    console.log @features

    @model = new @bayes.GaussianNB()
    @model.train(@features, @labels);
    return @updateGraphData()


  setParams: (newParams) ->
    @model = new @bayes.GaussianNB
    return

  updateGraphData: ->
#return the mesh_grid and training data for graphing service
    min_max = @get_boundary_from_feature()
    console.log min_max
    step_size = (min_max[1] - min_max[0]) / 50
    @mesh_grid_points = @mesh_grid_2d_init(min_max[0], min_max[1], step_size)
    console.log @mesh_grid_points
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
    result = []
    for x in @features
      x_column.push(parseFloat x[0])
      y_column.push(parseFloat x[1])

    result.push(Math.min.apply(null, x_column))
    result.push(Math.min.apply(null, y_column))
    result.push(Math.max.apply(null, x_column))
    result.push(Math.max.apply(null, y_column))
    final = []
    final.push(Math.min.apply(null, result))
    final.push(Math.max.apply(null, result))
    return final

  get_feature_projection_average: (featureIndex) ->
    result = 0
    count = 0
    for feature in @features
      result += parseFloat(feature[featureIndex])
      count += 1
    if count == 0  # avoid division by 0 error
      return 0
    else
      return result / count
