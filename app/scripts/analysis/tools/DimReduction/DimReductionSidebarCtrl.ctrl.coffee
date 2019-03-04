'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class DimReductionSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_dimReduction_dataService',
    'app_analysis_dimReduction_msgService'
    'app_analysis_dimReduction_algorithms'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @app_analysis_dimReduction_dataService
    @msgService = @app_analysis_dimReduction_msgService
    @algorithmsService = @app_analysis_dimReduction_algorithms
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
      @initConfLevelSlider()

    @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        if @dataType isnt obj.dataFrame.dataType
          # update local data type
          @dataType = obj.dataFrame.dataType
          # send update to main are actrl
          @msgService.broadcast 'dimReduction:updateDataType', obj.dataFrame.dataType
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

  initConfLevelSlider: () ->
    # add segments to a slider
    # https://designmodo.github.io/Flat-UI/docs/components.html#fui-slider
    $.fn.addSliderSegments = (amount, orientation) ->
      @.each () ->
        if orientation is "vertical"
          output = ''
          for i in [0..amount-2]
            output += '<div class="ui-slider-segment" style="top:' + 100 / (amount - 1) * i + '%;"></div>'
          $(this).prepend(output)
        else
          segmentGap = 100 / (amount - 1) + "%"
          segment = '<div class="ui-slider-segment" style="margin-left: ' + segmentGap + ';"></div>'
          $(this).prepend(segment.repeat(amount - 2))

    $slider = $("#slider")
    if $slider.length > 0
      $slider.slider(
        min: 5
        max: 30
        step: 5
        value: 10
        orientation: "horizontal"
        range: "min"
        slide: (event, ui) => @$timeout => @perplex = ui.value
      ).addSliderSegments($slider.slider("option").max)

  updateDataPoints: (data, labels=null) ->
    if data
      @msgService.broadcast 'dimReduction:updateDataPoints',
        data: data
        labels: labels
        header: ['x', 'y', @labelCol]
    else
      false

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
#    [@xCol, @yCol, ..., lastCol] = @numericalCols
    @clusterRunning = off
    if @labelCol
      @uniqueLabels =
        num: @uniqueVals (data.header.indexOf(@labelCol) for row in data.data)
        labelCol: @labelCol
    # @$timeout =>
    #   @updateDataPoints data

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

    # @updateDataPoints @dataFrame

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
        # @updateDataPoints(df)
        @ready = on

  getParams: () ->
    params =
      perplexity: @perplex
      metric: @distance

  ## Interface method to run algorithms
  run: ->
    data = @prepareData()
    if data and data.data
      runParams = @getParams()
      @algOn = on
      @running = 'spinning'
      runData = (row.map(Number) for row in data.data)
      res = @algorithmsService.run @selectedAlgorithm, runData, runParams, (res) =>
        @updateDataPoints res, data.labels
        @$timeout =>
          @algOn = off
          @running = 'hidden'
    else
      false

  reset: ->
    @algorithmsService.reset @selectedAlgorithm
    @updateDataPoints(@dataFrame, null, null)
