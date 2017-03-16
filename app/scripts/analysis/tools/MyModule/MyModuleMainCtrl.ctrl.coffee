'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleMainCtrl extends BaseCtrl
  @inject 'app_analysis_mymodule_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @app_analysis_mymodule_dataService
    @DATA_TYPES = @dataService.getDataTypes()

#    @title = 'Mymodule module'
#    @dataType = ''
#    @transforming = off
#    @transformation = ''
#    @transformations = []
#    @affinityMatrix = null
#
#    @showresults = off
#    @avgAccuracy = ''
#    @accs = {}
#
#    @dataPoints = null
#    @means = null
#    @assignments = null
#
#    @$scope.$on 'MyModule:updateDataPoints', (event, data) =>
#      @showresults = off if @showresults is on
## safe enforce $scope.$digest to activate directive watchers
#      @$timeout => @updateChartData(data)
#      console.log("I received data")
#
    @$scope.$on 'MyModule:updateDataType', (event, dataType) =>
      @dataType = dataType
      console.log("I received data")
#
#  prettifyArrayOutput: (arr) ->
#    if arr?
#      arr = arr.map (x) -> x.toFixed 3
#      '[' + arr.toString().split(',').join('; ') + ']'
#
#  showResults: (accuracy) ->
#    if Object.keys(accuracy).length isnt 0
#      @avgAccuracy = accuracy.average.toFixed(2)
#      delete accuracy.average
#      @accs = accuracy
#      @showresults = on
#
#  updateChartData: (data) ->
#    if data.dataPoints?
#      @dataPoints = data.dataPoints
#    @means = data.means
#    @assignments = data.labels
#
#  finish: (results=null) ->
#    @msgManager.broadcast 'cluster:done', results
#    showResults results
