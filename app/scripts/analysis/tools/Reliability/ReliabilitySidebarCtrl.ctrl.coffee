'use strict'

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
    @perfeval = off
    @dataType = null
    @intCols = []
    @chosenCols = []
    @metric = null
    @metrics = @tests.getMetricNames()

    @dataFrame = null

    @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        @dataType = @DATA_TYPES.FLAT
        # send update to main ctrl
        @msgService.broadcast 'reliability:updateDataType', obj.dataFrame.dataType
        # parse dataFrame
        @parseData obj
      else
        @dataType = @DATA_TYPES.NESTED

  parseData: (obj) ->
    @dataService.inferDataTypes obj.dataFrame, (resp) =>
      if resp and resp.dataFrame
        @dataFrame = resp.dataFrame
        cols = @dataFrame.header
        @intCols = (col for col, idx in cols when @dataFrame.types[idx] is 'integer')
        res = @processData @dataFrame
        @msgService.broadcast 'reliability:showResults', res

  processData: (obj=@dataFrame) ->
    if @chosenCols
      @perfeval = on
      chosenIdxs = @chosenCols.map (x) -> obj.header.indexOf x
      data = (row.filter((el, idx) -> idx in chosenIdxs) for row in obj.data)
      res = @tests.calculateMetric @metric, data, @confLevel
      @perfeval = off
      res


