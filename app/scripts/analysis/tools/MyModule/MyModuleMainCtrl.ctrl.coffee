'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleMainCtrl extends BaseCtrl
  @inject 'app_analysis_mymodule_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @DATA_TYPES = @dataService.getDataTypes()

    @title = 'My Awesome module'
    @dataType = ''
#     @transforming = off
#     @transformation = ''
#     @transformations = []
#     @affinityMatrix = null

#     @showresults = off
#     @avgAccuracy = ''
#     @accs = {}

    @dataPoints = null
#     @means = null
#     @assignments = null

    @$scope.$on 'myModule:displayDataPoints', (event, dataFrame) =>
# #      @showresults = off if @showresults is on
#       # safe enforce $scope.$digest to activate directive watchers
      @$timeout => @updateTable(dataFrame)

#     @$scope.$on 'cluster:updateDataType', (event, dataType) =>
#       @dataType = dataType
  updateTableData: (dataFrame) ->
    if dataFrame?
      @dataPoint
      @dataPoints = dataFrame
  # prettifyArrayOutput: (arr) ->
  #   if arr?
  #     arr = arr.map (x) -> x.toFixed 3
  #     '[' + arr.toString().split(',').join('; ') + ']'

  # showResults: (accuracy) ->
  #   if Object.keys(accuracy).length isnt 0
  #     @avgAccuracy = accuracy.average.toFixed(2)
  #     delete accuracy.average
  #     @accs = accuracy
  #     @showresults = on

  # updateChartData: (data) ->
  #   if data.dataPoints?
  #     if data.trueLabels?
  #       @dataPoints = data.dataPoints.map((row, i) ->
  #         row.push(data.trueLabels[i])
  #         return row
  #       )
  #     else
  #       @dataPoints = data.dataPoints
  #   @means = data.means
  #   @assignments = data.labels

  # finish: (results=null) ->
  #   @msgManager.broadcast 'cluster:done', results
  #   showResults results
