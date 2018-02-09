'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleMainCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @DATA_TYPES = @dataService.getDataTypes()

    @title = 'My Module'
    @dataType = ''
    @transforming = off
    @transformation = ''
    @transformations = []
    @affinityMatrix = null

    @dataPoints = null

    @$scope.$on 'mymodule:updateDataPoints', (event, data) =>
      # safe enforce $scope.$digest to activate directive watchers
      @$timeout => @updateChartData(data)

    @$scope.$on 'mymodule:updateDataType', (event, dataType) =>
      @dataType = dataType

  prettifyArrayOutput: (arr) ->
    if arr?
      arr = arr.map (x) -> x.toFixed 3
      '[' + arr.toString().split(',').join('; ') + ']'

  updateChartData: (data) ->
    if data.dataPoints?
      if data.trueLabels?
        @dataPoints = data.dataPoints.map((row, i) ->
          row.push(data.trueLabels[i])
          return row
        )
      else
        @dataPoints = data.dataPoints
