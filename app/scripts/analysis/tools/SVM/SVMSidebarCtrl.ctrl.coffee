'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

# MISSING: SENDING HYPERPARAMETERS TO ALGORITHMS

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

    @algParams = null
    @labelCol = null

    # dataset-specific
    @dataFrame = null
    @dataType = null
    @cols = []
    @chosenCols = []
    @numericalCols = []
    @categoricalCols = []
    @xCol = null
    @yCol = null

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

    # ASK BRADY
    @$timeout -> $('input[type=checkbox]').bootstrapSwitch()

    @dataService.getData().then (obj) =>
      if obj.dataFrame
        # make local copy of data
        @dataFrame = obj.dataFrame
        @parseData obj.dataFrame

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
    # Will probably make a longer if for each type of hyperparameter
    
    @$timeout =>
      #@updateDataPoints data

  uniqueVals: (arr) -> arr.filter (x, i, a) -> i is a.indexOf x

  ## Data preparation methods
  updateDataPoints: (data=null) ->
    if data
      xCol = data.header.indexOf @xCol unless !@xCol?
      yCol = data.header.indexOf @yCol unless !@yCol?
      sendData = ([row[xCol], row[yCol]] for row in data.data) unless @chosenCols.length < 2
      labels = (row[data.header.indexOf(@labelCol)] for row in data.data)
      @msgService.broadcast 'svm:updateDataPoints',
        dataPoints: sendData
        labels = labels

  updateChosenCols: () ->
    axis = [@xCol, @yCol]
    presentCols = ([name, idx] for name, idx in @chosenCols when name in axis)
    # if current X and Y are not among selected anymore
    switch presentCols.length
      when 0
        @xCol = if @chosenCols.length > 0 then @chosenCols[0] else null
        @yCol = if @chosenCols.length > 1 then @chosenCols[1] else null
      when 1
        upd = if @chosenCols.length > 1 then @chosenCols.find (e, i) -> i isnt presentCols[0][1] else null
        [@xCol, @yCol] = axis.map (c) -> if c isnt presentCols[0][0] then upd else c

    @updateDataPoints @dataFrame

  # get requested columns from data
  prepareData: () ->
    data = @dataFrame

    if @chosenCols.length > 1

      # get indices of feats to visualize in array of chosen
      xCol = @chosenCols.indexOf @xCol
      yCol = @chosenCols.indexOf @yCol
      chosenIdxs = @chosenCols.map (x) -> data.header.indexOf x

      # if usage of labels is on

      labelColIdx = data.header.indexOf @labelCol
      labels = (row[labelColIdx] for row in data.data)

      data = (row.filter((el, idx) -> idx in chosenIdxs) for row in data.data)

      obj =
        data: data
        labels: labels
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

  startAlgorithm: ->
    algData = @sendData()
    @msgService.broadcast 'svm:startAlgorithm',
      dataFrame: algData.data
      labels: algData.labels


  reset: ->
    @algorithmsService.reset @selectedAlgorithm
    #@updateDataPoints(@dataFrame, null, null)