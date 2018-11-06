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
    @options = null
    @lables = null

    #runtime variables
    @svmModel = null
    @features = null
    @labels = null


    # One vs. All , Multi Class / Label
    @svmModelArray = []
    @svmMarginPrediciton = []
    @uniqueLabelArray = []

    # Variables for Graphing Service
    @mesh_grid_points = null
    @mesh_grid_label = []
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
    console.log "features"
    console.log @features
    for x in @labels
      if @uniqueLabelArray.includes(x) == false
        @uniqueLabelArray.push(x)
    if @uniqueLabelArray.length > 2
      return @trainMultiClass()
    else
      @svmModel.train(@features, @labels);
      return @updateGraphData()

  trainMultiClass: () ->
    console.log "features MultiClass"
    console.log @features
    uniqueLabelArray = @uniqueLabelArray

    min_max = @get_boundary_from_feature()
    console.log min_max
    @mesh_grid_points = @mesh_grid_2d_init(min_max[0], min_max[1], 0.1)
    console.log @mesh_grid_points
    # append feature projection points to mesh_grid_points
    for grid in @mesh_grid_points
      featureIndex = 2
      while featureIndex < @features[0].length
        grid.push(@get_feature_projection_average(featureIndex))
        featureIndex += 1

    console.log @mesh_grid_points

    for label in uniqueLabelArray
      newLabels = []
      for oldLabel in @labels
        if oldLabel != label
          newLabels.push(-1)
        else
          newLabels.push(1)
      svmModel = new @svm @options
      console.log @features
      console.log newLabels
      svmModel.train(@features, newLabels)
      @svmModelArray.push(svmModel)
      console.log @svmModelArray

    for point in @mesh_grid_points
      Margins = []
      for svmModel in @svmModelArray
        Margins.push(svmModel.margin([point])[0])
      MarginIndex = 0
      maxMarginIndex = 0
      maxMargin = Margins[0]
      while MarginIndex <= Margins.length
        if Margins[MarginIndex] > maxMargin
          maxMargin = Margins[MarginIndex]
          maxMarginIndex = MarginIndex
        MarginIndex += 1
      @mesh_grid_label.push(uniqueLabelArray[maxMarginIndex])

    result =
      mesh_grid_points: @mesh_grid_points
      mesh_grid_labels: @mesh_grid_label
      features: @features
      labels: @labels
    console.log('finished training')
    return result





  setParams: (newParams) ->
    @params = newParams
    options =
      C: newParams.c
      tol: 10e-4
      maxPasses: 10
      maxIterations: 1000000
      kernel: newParams.kernel
      kernelOptions: sigma: 0.5
    @options = options
    @svmModel = new @svm options
    return

  updateGraphData: ->
    #return the mesh_grid and training data for graphing service
    min_max = @get_boundary_from_feature()
    console.log min_max
    @mesh_grid_points = @mesh_grid_2d_init(min_max[0], min_max[1], 0.1)
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
