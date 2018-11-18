'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ClassificationSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_classification_dataService',
    'app_analysis_classification_msgService'
    'app_analysis_classification_algorithms'
    'app_analysis_classification_metrics'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @app_analysis_classification_dataService
    @msgService = @app_analysis_classification_msgService
    @algorithmsService = @app_analysis_classification_algorithms
    @algorithms = @algorithmsService.getNames()

    @DATA_TYPES = @dataService.getDataTypes()

    # Algorithm parameters
    @algParams = null

    # Data related columns
    @dataFrame = null
    @dataType = null
    @cols = []
    @chosenCols = []
    @numericalCols = []
    @categoricalCols = []
    @xCol = null
    @yCol = null
    @labelCol = null

    # Variables for control
    @ready = off
    @running = off

    # choose first algorithm as default one
    if @algorithms.length > 0
      @selectedAlgorithm = @algorithms[0]
      @updateAlgControls()

    @$timeout -> $('input[type=checkbox]').bootstrapSwitch()

    @dataService.getData().then (obj) =>
      if obj.dataFrame
        # make local copy of data
        @dataFrame = obj.dataFrame
        @parseData obj.dataFrame

  updateAlgControls: () ->
    # Get parameters of algorithm after choosing algorithm
    @algParams = @algorithmsService.getParamsByName @selectedAlgorithm

  # update data-driven sidebar controls
  updateSidebarControls: (data) ->
    # Get columns and types of columns
    @cols = data.header
    @numericalCols = (col for col, idx in @cols when data.types[idx] in ['integer', 'number'])
    @categoricalCols = (col for col, idx in @cols when data.types[idx] in ['string', 'integer'])

  uniqueVals: (arr) -> arr.filter (x, i, a) -> i is a.indexOf x

  ## Data preparation methods
  updateDataPoints: (data=null) ->
    # Update visualization of datapoints
    if data
      xCol = data.header.indexOf @xCol unless !@xCol?
      yCol = data.header.indexOf @yCol unless !@yCol?
      @sendData = ([row[xCol], row[yCol]] for row in data.data) unless @chosenCols.length < 2
      @legendDict = {}
      labelDict = {}
      # Make mapping to handle all kinds of labels
      if @labelCol
        labelIndex = data.header.indexOf @labelCol
        @uniqueLabels = @uniqueVals (row[labelIndex] for row in data.data)

        if @uniqueLabels.length != 2
          labelDict[label] = i for label, i in @uniqueLabels

        else
          labelDict[@uniqueLabels[0]] = 1
          labelDict[@uniqueLabels[1]] = -1

        # Use map to create numeric labels
        @mappedLabels = (labelDict[row[data.header.indexOf(@labelCol)]] for row in data.data)
        # Reverse dict for the legend
        @legendDict[value] = key for key, value of labelDict
      else
        @mappedLabels = (row[data.header.indexOf(@labelCol)] for row in data.data)

      # Broadcast data to main controller
      @msgService.broadcast 'classification:updateDataPoints',
        dataPoints: @sendData
        labels: @mappedLabels
        legend: @legendDict
        xCol: @xCol
        yCol: @yCol


  updateChosenCols: () ->
    # Update chosen columns
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

    if @chosenCols.length > 1
      @updateDataPoints @dataFrame

  # get requested columns from data
  prepareData: () ->
    # Prepare data for training
    data = @dataFrame

    if @chosenCols.length > 1

      # get indices of feats to visualize in array of chosen
      xCol = @chosenCols.indexOf @xCol
      yCol = @chosenCols.indexOf @yCol
      chosenIdxs = @chosenCols.map (x) -> data.header.indexOf x

      labelColIdx = data.header.indexOf @labelCol

      data = (row.filter((el, idx) -> idx in chosenIdxs) for row in data.data)

      obj =
        features: data
        labels: @mappedLabels
        xIdx: xCol
        yIdx: yCol

    else false

  parseData: (data) ->
    # Parsing data when reading in dataframe
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
    # Tells main controller to start training

    algData = @prepareData()
    @running = on

    # Sets hyperparameters
    if @algParams.c
      hyperPar =
        kernel: @selectedKernel
        c: @selectedC

    if @algParams.k
      hyperPar =
        k: @selectedK

    # Set data to model
    @algorithmsService.passDataByName(@selectedAlgorithm, algData)
    # Send selectedAlgorithm and hyperparameters
    @algorithmsService.setParamsByName(@selectedAlgorithm, hyperPar)

    @msgService.broadcast 'classification:startAlgorithm',
      dataPoints: algData.data
      labels: algData.labels
      model: @selectedAlgorithm
      xCol: @xCol
      yCol: @yCol


  reset: ->
    # Resetting stuff in algorithms
    @algorithmsService.reset @selectedAlgorithm

    # Resetting main
    @msgService.broadcast 'classification:resetGrid',
      message: "reset grid"
      xCol : @xCol
      yCol : @yCol
      labels: @mappedLabels
      dataPoints: @sendData
      legend: @legendDict

    @running = off
    @$timeout -> $('input[type=checkbox]').bootstrapSwitch()


