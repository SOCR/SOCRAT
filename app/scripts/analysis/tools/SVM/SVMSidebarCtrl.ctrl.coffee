'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class SVMSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_svm_dataService',
    'app_analysis_svm_msgService'
    'app_analysis_svm_algorithms'
    'app_analysis_svm_metrics'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @app_analysis_svm_dataService
    @msgService = @app_analysis_svm_msgService
    @algorithmsService = @app_analysis_svm_algorithms
    @algorithms = @algorithmsService.getNames()

    @DATA_TYPES = @dataService.getDataTypes()
    # set up data and algorithm-agnostic controls
    @useLabels = off
    @uniqueLabels =
      labelCol: null
      num: null
    @algParams = null

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


    # set up data controls
    @ready = off

    # dataset-specific
    @dataFrame = null

    @kernels = @app_analysis_svm_metrics.getKernelNames()

    # choose first algorithm as default one
    if @algorithms.length > 0
      @selectedAlgorithm = @algorithms[0]
      @updateAlgControls()

    # choose first kernel as default one
    if @kernels.length > 0
      @selectedKernel = @kernels[0]

    @$timeout -> $('input[type=checkbox]').bootstrapSwitch()

    @dataService.getData().then (obj) =>
      if obj.dataFrame
        @msgService.broadcast 'svm:displayData', obj.dataFrame
        # make local copy of data
        @dataFrame = obj.dataFrame
        @parseData obj.dataFrame
      else
        # TODO: add processing for nested object
        console.log 'NESTED DATASET'

  updateAlgControls: () ->
    @algParams = @algorithmsService.getParamsByName @selectedAlgorithm

  # update data-driven sidebar controls
  updateSidebarControls: (data) ->
    @cols = data.header
    @numericalCols = (col for col, idx in @cols when data.types[idx] in ['integer', 'number'])
    @categoricalCols = (col for col, idx in @cols when data.types[idx] in ['string', 'integer'])
    # make sure number of unique labels is less than maximum number of classes for visualization
    if @algParams.c
      [minC, ..., maxC] = @algParams.c
      @categoricalCols = @categoricalCols.filter (x, i) =>
        #@uniqueVals(colData[@cols.indexOf(x)]).length < maxK
    if @labelCol
      @uniqueLabels =
        num: @uniqueVals (data.header.indexOf(@labelCol) for row in data.data)
        labelCol: @labelCol
    
    @$timeout =>
      #@updateDataPoints data

  uniqueVals: (arr) -> arr.filter (x, i, a) -> i is a.indexOf x

  ## Data preparation methods

  # get requested columns from data
  prepareData: () ->
    data = @dataFrame

    if @chosenCols.length > 1

      # get indices of feats to visualize in array of chosen
      xCol = @chosenCols.indexOf @xCol
      yCol = @chosenCols.indexOf @yCol
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

    else false

  parseData: (data) ->
    @dataService.inferDataTypes data, (resp) =>
      if resp? and resp.dataFrame? and resp.dataFrame.data?
        df = @dataFrame
        # update data types with inferred
        for type, idx in df.types
         df.types[idx] = resp.dataFrame.data[idx]
        @updateSidebarControls(df)
        #@updateDataPoints(df)
        @ready = on

  reset: ->
    @algorithmsService.reset @selectedAlgorithm
    #@updateDataPoints(@dataFrame, null, null)
