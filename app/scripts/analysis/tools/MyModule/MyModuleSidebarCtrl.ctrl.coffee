'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleSidebarCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService',
    'socrat_analysis_mymodule_msgService'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @msgService = @socrat_analysis_mymodule_msgService
    @DATA_TYPES = @dataService.getDataTypes()

    # set up data controls
    @useLabels = off
    @ready = off
    @uniqueLabels =
      labelCol: null
      num: null

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

    @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        if @dataType isnt obj.dataFrame.dataType
          # update local data type
          @dataType = obj.dataFrame.dataType
          # send update to main are actrl
          @msgService.broadcast 'mymodule:updateDataType', obj.dataFrame.dataType
        # make local copy of data
        @dataFrame = obj.dataFrame
        # parse dataFrame
        @parseData obj.dataFrame
      else
        # TODO: add processing for nested object
        console.log 'NESTED DATASET'

    @$timeout -> $('input[type=checkbox]').bootstrapSwitch()

  updateDataPoints: (data=null, labels=null) ->
    if data
      trueLabels = null
      if @labelCol
        trueLabels = (row[data.header.indexOf(@labelCol)] for row in data.data)
        @uniqueLabels =
          num: @uniqueVals (data.header.indexOf(@labelCol) for row in data.data)
          labelCol: @labelCol
      xCol = data.header.indexOf @xCol unless !@xCol?
      yCol = data.header.indexOf @yCol unless !@yCol?
      data = ([row[xCol], row[yCol]] for row in data.data) unless @chosenCols.length < 2
    @msgService.broadcast 'mymodule:updateDataPoints',
      dataPoints: data
      labels: labels
      trueLabels: trueLabels

  # update data-driven sidebar controls
  updateSidebarControls: (data) ->
    @cols = data.header
    @numericalCols = (col for col, idx in @cols when data.types[idx] in ['integer', 'number'])
    @categoricalCols = (col for col, idx in @cols when data.types[idx] in ['string', 'integer'])
    if @labelCol
      @uniqueLabels =
        num: @uniqueVals (data.header.indexOf(@labelCol) for row in data.data)
        labelCol: @labelCol
    @$timeout =>
      @updateDataPoints data

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
        @updateDataPoints(df)
        @ready = on
