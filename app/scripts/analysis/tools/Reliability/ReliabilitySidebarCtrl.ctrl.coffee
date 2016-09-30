'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ReliabilitySidebarCtrl extends BaseCtrl
  @inject 'app_analysis_reliability_dataService',
    'app_analysis_reliability_msgService'
    'app_analysis_reliability_algorithms'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @app_analysis_reliability_dataService
    @msgService = @app_analysis_reliability_msgService
    @DATA_TYPES = @dataService.getSupportedDataTypes()
    @tests = @app_analysis_reliability_tests

    @nCols = '5'
    @nRows = '5'
    @confLevel = 0.95
    @perfeval = off

    @dataService.getData().then (obj) =>
    if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
      @dataType = @DATA_TYPES.FLAT
      # send update to main are actrl
      @msgService.broadcast 'reliability:updateDataType', obj.dataFrame.dataType
      # parse dataFrame
      res = @parseData obj.dataFrame
      @msgService.broadcast 'reliability:showResults', res
    else
    @dataType = @DATA_TYPES.NESTED

  parseData: (obj) ->
    @nRows = obj.data?.length
    @nCols = obj.data[0]?.length
    @perfeval = on
    res = tests.cAlphaAndConfIntervals obj, @confLevel


