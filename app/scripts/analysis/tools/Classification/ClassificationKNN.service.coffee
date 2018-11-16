'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_classification_knn
  @desc: Performs k Nearest Neighbor classification
###

module.exports = class NaiveBayes extends BaseService
  @inject '$timeout', 'app_analysis_classification_metrics'

  initialize: () ->
    @metrics = @app_analysis_classification_metrics

    @bayes = require 'ml-knn'

    @name = 'kNN'

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

    @ks = [1..10]

    # module hyperparameters
    @params = 
      k: @ks

  getName: -> @name
  getParams: -> @params

  saveData: (data) ->
    @features = data.features
    @labels = data.labels
    @xIdx = data.xIdx
    @yIdx = data.yIdx

  train: (data) ->
    console.log "features"
    console.log @features
    options =
      k: @k
    @model = new @bayes(@features, @labels, options)
    # @model.train(@features, @labels)
    return @updateGraphData()


  setParams: (newParams) ->
    # @model = new @bayes.GaussianNB
    @k = newParams.k

    return

  updateGraphData: ->
    #return the mesh_grid and training data for graphing service
    min_max = @get_boundary_from_feature()
    console.log min_max
    step_size_x = (min_max[1] - min_max[0]) / 100
    step_size_y = (min_max[3] - min_max[2]) / 100
    @mesh_grid_points = @mesh_grid_2d_init(min_max, step_size_x, step_size_y)
    console.log @mesh_grid_points
    @mesh_grid_label = @mesh_grid_predict_label(@model, @mesh_grid_points)
    console.log @mesh_grid_label

    # @features = (row.filter((el, idx) -> idx in [@xIdx, @yIdx]) for row in @features)
    features = []
    for row in @features
      features.push [row[@xIdx], row[@yIdx]]

    result =
      mesh_grid_points: @mesh_grid_points
      mesh_grid_labels: @mesh_grid_label
      features: features
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
  mesh_grid_2d_init: (min_max, step_x, step_y) ->
    # Initialize the mesh_grid points
    x_low = min_max[0]
    x_high = min_max[1]
    y_low = min_max[2]
    y_high = min_max[3]
    grid_array = []
    if x_low >= x_high or y_low >= y_high
      return []

    for i in [x_low..x_high] by step_x

      for j in [y_low..y_high] by step_y
        grid_element = [i, j]
        grid_array.push grid_element

    # if low_bound >= high_bound
    #   return []
    # i = low_bound
    # while i < high_bound
    #   j = low_bound
    #   while j < high_bound
    #     grid_element = [i, j]
    #     grid_array.push grid_element
    #     j += step_size
    #   i += step_size

    return grid_array

  mesh_grid_predict_label: (model, mesh_grid) ->
    # return the mesh_grid with the prediction label
    pred = model.predict(mesh_grid)
    return pred

  get_boundary_from_feature: () ->
    # get minimum of x
    x_column = []
    y_column = []
    result = []
    for x in @features
      x_column.push(parseFloat x[@xIdx])
      y_column.push(parseFloat x[@yIdx])

    result.push(Math.min.apply(null, x_column))
    result.push(Math.max.apply(null, x_column))
    result.push(Math.min.apply(null, y_column))
    result.push(Math.max.apply(null, y_column))
    # final = []
    # final.push(Math.min.apply(null, result))
    # final.push(Math.max.apply(null, result))
    return result
    # return final

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
