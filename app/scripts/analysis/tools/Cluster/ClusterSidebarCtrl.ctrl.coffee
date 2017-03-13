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
    @reportAccuracy = on
    @clusterRunning = off
    @ready = off
    @running = 'hidden'
    @uniqueLabels =
      labelCol: null
      num: null
    @algParams = null
    # TODO: allow user control of delay
    @iterDelay = 750

    # dataset-specific
    @dataFrame = null
    @dataType = null
    @cols = []
    @chosenCols = []
    @numericalCols = []
    @categoricalCols = []
    @xCol = null
    @yCol = null
    @labelCol = null

    # choose first algorithm as default one
    if @algorithms.length > 0
      @selectedAlgorithm = @algorithms[0]
      @updateAlgControls()

    @dataService.b().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        if @dataType isnt obj.dataFrame.dataType
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

    @$timeout -> $('input[type=checkbox]').bootstrapSwitch()

  updateAlgControls: () ->
    @algParams = @algorithmsService.getParamsByName @selectedAlgorithm

  updateDataPoints: (data=null, means=null, labels=null) ->
    if data
      if @labelCol
        @uniqueLabels =
          num: @uniqueVals (data.header.indexOf(@labelCol) for row in data.data)
          labelCol: @labelCol
      xCol = data.header.indexOf @xCol
      yCol = data.header.indexOf @yCol
      data = ([row[xCol], row[yCol]] for row in data.data)
    @msgService.broadcast 'cluster:updateDataPoints',
      dataPoints: data
      means: means
      labels: labels

  # update data-driven sidebar controls
  updateSidebarControls: (data) ->
    @cols = data.header
    @numericalCols = (col for col, idx in @cols when data.types[idx] in ['integer', 'number'])
    @categoricalCols = (col for col, idx in @cols when data.types[idx] in ['string', 'integer'])
    # make sure number of unique labels is less than maximum number of clusters for visualization
    if @algParams.k
      [minK, ..., maxK] = @algParams.k
      colData = d3.transpose(data.data)
      @categoricalCols = @categoricalCols.filter (x, i) =>
        @uniqueVals(colData[@cols.indexOf(x)]).length < maxK
    [@xCol, @yCol, ..., lastCol] = @numericalCols
    @clusterRunning = off
    if @labelCol
      @uniqueLabels =
        num: @uniqueVals (data.header.indexOf(@labelCol) for row in data.data)
        labelCol: @labelCol
    @$timeout =>
      @updateDataPoints data

  uniqueVals: (arr) -> arr.filter (x, i, a) -> i is a.indexOf x

  detectK: () ->
    detectedK = @detectKValue()
    @setDetectedKValue detectedK

  setDetectedKValue: (detectedK) ->
    if detectedK.num <= 10
      @uniqueLabels = detectedK
      @k = detectedK.num
      # TODO: add success messages
    else
      # TODO: create popup with warning message
      console.log 'KMEANS: k is more than 10'

  detectKValue: () ->
    # extra check that labels are on
    if @dataFrame and @labelCol
      labelCol = @dataFrame.header.indexOf @labelCol
      labels = (row[labelCol] for row in @dataFrame.data)
      uniqueLabels = @uniqueVals labels
      uniqueLabels =
        labelCol: @labelCol
        num: uniqueLabels.length

  ## Data preparation methods

  # get requested columns from data
  prepareData: () ->
    data = @dataFrame

    if @chosenCols.length > 1

      xCol = data.header.indexOf @xCol
      yCol = data.header.indexOf @yCol
      chosenIdxs = @chosenCols.map (x) -> data.header.indexOf x

      # if usage of labels is on
      if @labelCol
        labelColIdx = data.header.indexOf @labelCol
        labels = (row[labelColIdx] for row in data.data)
      else
        labels = null

      data = (row.filter((el, idx) -> idx in chosenIdxs) for row in data.data)

      # re-check if possible to compute accuracy
      if @k is @uniqueLabels.num and @accuracyon
        acc = on

      obj =
        data: data
        labels: labels
        xCol: xCol
        yCol: yCol
        acc: acc

    else false

  parseData: (data) ->
    @dataService.inferDataTypes data, (resp) =>
      if resp and resp.dataFrame
        @updateSidebarControls(resp.dataFrame)
        @updateDataPoints(resp.dataFrame)
        @ready = on

  ## Interface method to run clustering

  runClustering: ->
    clustData = @prepareData()
    @kmeanson = on
    @running = 'spinning'
    res = @algorithmsService.cluster @selectedAlgorithm, clustData, @k, @initMethod, @distance, @iterDelay, (res) =>
      xyMeans = ([row.val[clustData.xCol], row.val[clustData.yCol]] for row in res.centroids)
      @updateDataPoints null, xyMeans, res.labels
      @$timeout =>
        @kmeanson = off
        @running = 'hidden'

  stepClustering: ->
    clustData = @prepareData()
    @kmeanson = on
    @running = 'spinning'
    res = @algorithmsService.clusterStep @selectedAlgorithm, clustData, @k, @initMethod, @distance
    xyMeans = ([row.val[clustData.xCol], row.val[clustData.yCol]] for row in res.centroids)
    @updateDataPoints null, xyMeans, res.labels
    @$timeout =>
      @kmeanson = off
      @running = 'hidden'

  reset: ->
    @algorithmsService.reset @selectedAlgorithm
    @updateDataPoints(@dataFrame, null, null)


