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
    @useLabels = off
    @useAllData = on
    @reportAccuracy = on
    @clusterRunning = off
    @ready = off
    @running = 'hidden'
    @uniqueLabels =
      labelCol: null
      num: null
    @algParams = null

    # dataset-specific
    @dataFrame = null
    @dataType = null
    @cols = []
    @xCol = null
    @yCol = null
    @labelCol = null

    $('input[type=checkbox]').bootstrapSwitch()

    # choose first algorithm as default one
    if @algorithms.length > 0
      @selectedAlgorithm = @algorithms[0]
      @updateAlgControls()

    @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        # update local data type
        @dataType = obj.dataFrame.dataType
        # send update to main are actrl
        @msgService.broadcast 'cluster:updateDataType', obj.dataFrame.dataType
        # make local copy of data
        @dataFrame = obj.dataFrame
        # parse dataFrame
        @parseData obj.dataFrame
      else
        # TODO: add processing for nested object
        console.log 'NESTED DATASET'

  updateAlgControls: () ->
    @algParams = @algorithmsService.getParamsByName @selectedAlgorithm

  updateDataPoints: (data=@dataFrame) ->
    xCol = data.header.indexOf @xCol
    yCol = data.header.indexOf @yCol
    data = ([row[xCol], row[yCol]] for row in data.data)
    @msgService.broadcast 'cluster:updateDataPoints', data

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
  prepareData: () ->
    data = @dataFrame
    xCol = data.header.indexOf @xCol
    yCol = data.header.indexOf @yCol

    # if usage of labels is on
    if @useLabels
      labelCol = data.header.indexOf @labelCol
      labels = (row[labelCol] for row in data.data)
    else
      labels = null

    # if clustering on the whole dataset is on
    if @useAllData
      rawData =
        if labels
          data = (row.filter((el, idx) -> idx isnt labelCol) for row in data.data)
    else
      # get data for 2 chosen columns
      data = ([row[xCol], row[yCol]] for row in data.data)

    # re-check if possible to compute accuracy
    if @useLabels and @k is @numUniqueLabels.num and @accuracyon
      acc = on

    obj =
      data: data
      labels: labels
      xCol: xCol
      yCol: yCol
      acc: acc

  # call k-means service with parsed data and current controls values
  cluster: (data) ->
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
    @ready = on

  runClustering: ->
    clustData = prepareData()
    @cluster clustData

