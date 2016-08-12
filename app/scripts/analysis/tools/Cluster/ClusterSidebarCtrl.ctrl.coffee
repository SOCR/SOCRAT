'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ClusterSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_cluster_dataService',
    'app_analysis_cluster_msgService'
    'app_analysis_cluster_algorithms'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @app_analysis_cluster_dataService
    @msgService = @app_analysis_cluster_msgService
    @algorithmsService = @app_analysis_cluster_algorithms
    @algorithms = @algorithmsService.getNames()
    @DATA_TYPES = @dataService.getDataTypes()
    # set up data and algorithm-agnostic controls
    @useLabels = on
    @useAllData = on
    @reportAccuracy = on
    @clusterRunning = off
    @cols = []
    @dataType = null

    if @algorithms.length > 0
      @selectedAlgorithm = @algorithms[0]

    @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        @dataType = obj.dataFrame.dataType
        @msgService.broadcast 'kmeans:updateDataType', obj.dataFrame.dataType
        @parseData obj.dataFrame
      else
        # TODO: add processing for nested object
        console.log 'NESTED DATASET'

  updateDataPoints: (data) ->
    xCol = data.header.indexOf @xCol
    yCol = data.header.indexOf @yCol
    data = ([row[xCol], row[yCol]] for row in data.data)
    @msgService.broadcast 'cluster:updateDataPoints', data

  # set initial values for sidebar controls
  setSidebarControls: (initControlValues) ->
    params = @algorithm.getParameters()
    @ks = [params.minK..params.maxK]
    @distances = params.distances
    @inits = params.initMethods

    @cols = []
    @kmeanson = on
    @running = 'hidden'
    @uniqueLabels =
      labelCol: null
      num: null

    @k = initControlValues.k if initControlValues.k in @ks
    @dist = initControlValues.distance if initControlValues.distance in @distances
    @initMethod = initControlValues.initialisation if initControlValues.initialisation in @inits
    @labelson = initControlValues.labelson
    @wholedataseton = initControlValues.wholedataseton
    @accuracyon = initControlValues.accuracyon

  # update data-driven sidebar controls
  updateSidebarControls: (data) ->
    @cols = data.header
    [firstCol, secondCol, ..., lastCol] = @cols
    @xCol = firstCol
    @yCol = secondCol
    @labelCol = lastCol
    @clusterRunning = off
    if @useLabels
      @numUniqueLabels = @detectK data
    @$timeout =>
      @updateDataPoints data

  detectK: (data) ->
    detectedK = @detectKValue data
    @setDetectedKValue detectedK

  setDetectedKValue: (detectedK) ->
    if detectedK.num <= 10
      @uniqueLabels = detectedK
      @k = detectedK.num
      # TODO: add success messages
    else
      # TODO: create popup with warning message
      console.log 'KMEANS: k is more than 10'

  detectKValue: (data) ->
    # extra check that labels are on
    if @useLabels
      labelCol = data.header.indexOf @labelCol
      labels = (row[labelCol] for row in data.data)
      uniqueLabels = labels.filter (x, i, a) -> i is a.indexOf x
      uniqueLabels =
        labelCol: @labelCol
        num: uniqueLabels.length

  # get requested columns from data
  parseDataForKMeans: (data) ->
    xCol = data.header.indexOf @xCol
    yCol = data.header.indexOf @yCol

    # if usage of labels is on
    if @labelson
      labelCol = data.header.indexOf @labelCol
      labels = (row[labelCol] for row in data.data)
    else
      labels = null

    # if clustering on the whole dataset is on
    if @wholedataseton
      rawData =
        if labels
          data = (row.filter((el, idx) -> idx isnt labelCol) for row in data.data)
    else
      # get data for 2 chosen columns
      data = ([row[xCol], row[yCol]] for row in data.data)

    # re-check if possible to compute accuracy
    if @labelson and @k is @numUniqueLabels.num and @accuracyon
      acc = on

    obj =
      data: data
      labels: labels
      xCol: xCol
      yCol: yCol
      acc: acc

  # call k-means service with parsed data and current controls values
  callKMeans: (data) ->
    @kmeanson = on
    @running = 'spinning'
    @$on 'kmeans:done', (event, results) ->
      # use timeout to call $digest
      $timeout ->
        @kmeanson = off
        @running = 'hidden'
    kmeans.run data, @k, @dist, @initMethod

  parseData: (data) ->
    @updateSidebarControls(data)
    @updateDataPoints(data)

  runClustering: (data) ->
    _data = parseDataForKMeans data
    callKMeans _data

