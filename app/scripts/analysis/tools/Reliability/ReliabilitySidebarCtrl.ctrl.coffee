'use strict'

require 'jquery-ui/ui/widgets/slider'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ReliabilitySidebarCtrl extends BaseCtrl
  @inject 'app_analysis_reliability_dataService',
    'app_analysis_reliability_msgService'
    'app_analysis_reliability_tests'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @app_analysis_reliability_dataService
    @msgService = @app_analysis_reliability_msgService
    @DATA_TYPES = @dataService.getDataTypes()
    @tests = @app_analysis_reliability_tests

    @nCols = '5'
    @nRows = '5'
    @confLevel = 0.95
    @sliderTooltipIsOpen = off
    @perfeval = off
    @dataType = null
    @intCols = []
    @chosenCols = []
    @metric = null
    @metrics = @tests.getMetricNames()

    @dataFrame = null
    @initConfLevelSlider()

    @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        @dataType = @DATA_TYPES.FLAT
        # send update to main ctrl
        @msgService.broadcast 'reliability:updateDataType', obj.dataFrame.dataType
        @dataFrame = obj.dataFrame
        # parse dataFrame
        @parseData obj
      else
        @dataType = @DATA_TYPES.NESTED

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
        min: 90
        max: 99
        value: 95
        orientation: "horizontal"
        range: "min"
        slide: (event, ui) => @$timeout => @confLevel = ui.value / 100
      ).addSliderSegments($slider.slider("option").max)

  updateMetric: () ->
    res = @processData @dataFrame
    @msgService.broadcast 'reliability:showResults',
      metric: @metric
      data: res

  parseData: (obj) ->
    @dataService.inferDataTypes obj.dataFrame, (resp) =>
      if resp and resp.dataFrame and resp.dataFrame.data
        # update data types with inferred
        for type, idx in @dataFrame.types
          @dataFrame.types[idx] = resp.dataFrame.data[idx]
        # get only integer columns
        cols = @dataFrame.header
        @intCols = (col for col, idx in cols when @dataFrame.types[idx] is 'integer')
        res = @processData @dataFrame
        @msgService.broadcast 'reliability:showResults',
          metric: @metric
          data: res

  processData: (obj=@dataFrame) ->
    if @chosenCols.length is 0
      if @intCols.length > 0
        @chosenCols = @intCols
      else return false
    @perfeval = on
    chosenIdxs = @chosenCols.map (x) -> obj.header.indexOf x
    data = (row.filter((el, idx) -> idx in chosenIdxs) for row in obj.data)
    res = @tests.calculateMetric @metric, data, @confLevel
    @perfeval = off
    res


