'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_classification_csvc
  @desc: Performs SVM classification (C formulation)
###

module.exports = class ClassificationCSVC extends BaseService
  @inject '$timeout', 'app_analysis_classification_metrics'

  initialize: () ->
    @metrics = @app_analysis_classification_metrics
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
    @xIdx = data.xIdx
    @yIdx = data.yIdx

  train: (data) ->

    if @xIdx != 0
      for point in @features
        temp = point[0]
        point[0] = point[@xIdx]
        point[@xIdx] = temp
      @xIdx = 0
      if @yIdx == 0
        @yIdx = 1

    if @yIdx != 1
      for point in @features
        temp = point[1]
        point[1] = point[@yIdx]
        point[@yIdx] = temp
      @yIdx = 1


    @svmModel = new @svm @options
    for x in @labels
      if @uniqueLabelArray.includes(x) == false
        @uniqueLabelArray.push(x)
    if @uniqueLabelArray.length > 2
      return @trainMultiClass()
    else
      return @updateGraphData()

  trainMultiClass: () ->

    uniqueLabelArray = @uniqueLabelArray

    min_max = @get_boundary_from_feature()
    step_size_x = (min_max[1] - min_max[0]) / 100
    step_size_y = (min_max[3] - min_max[2]) / 100
    @mesh_grid_points = @mesh_grid_2d_init(min_max, step_size_x, step_size_y)

    # append feature projection points to mesh_grid_points
    for grid in @mesh_grid_points
      featureIndex = 0
      while featureIndex < @features[0].length
        if featureIndex != @xIdx and featureIndex != @yIdx
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

      svmModel.train(@features, newLabels)

      @svmModelArray.push(svmModel)


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
    options =
      C: newParams.c
      tol: 10e-4
      maxPasses: 10
      maxIterations: 1000000
      kernel: newParams.kernel
      kernelOptions: sigma: 0.5
    @options = options
    return

  updateGraphData: ->

    min_max = @get_boundary_from_feature()
    step_size_x = (min_max[1] - min_max[0]) / 100
    step_size_y = (min_max[3] - min_max[2]) / 100
    @mesh_grid_points = @mesh_grid_2d_init(min_max, step_size_x, step_size_y)

    # append feature projection points to mesh_grid_points
    for grid in @mesh_grid_points
      featureIndex = 0
      while featureIndex < @features[0].length
        if featureIndex != @xIdx and featureIndex != @yIdx
          grid.push(@get_feature_projection_average(featureIndex))
        featureIndex += 1


    console.log @labels
    console.log @features
    @svmModel.train(@features, @labels)
    @mesh_grid_label = @mesh_grid_predict_label(@svmModel, @mesh_grid_points)

    console.log @svmModel

    console.log @mesh_grid_label

    result =
      mesh_grid_points: @mesh_grid_points
      mesh_grid_labels: @mesh_grid_label
      features: @features
      labels: @labels
    console.log('finished training')
    return result

  getUniqueLabels: (labels) -> labels.filter (x, i, a) -> i is a.indexOf x

  initLabels: (l, k) ->
    labels = []
    labels.push Math.floor(Math.random() * k) for i in [0..l]
    labels

  reset: ()->
    @done = off
    @iter = 0
    @initialize()
    console.log 'service reset'

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
