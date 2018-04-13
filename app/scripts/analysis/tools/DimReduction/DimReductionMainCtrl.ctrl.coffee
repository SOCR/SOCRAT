'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class DimReductionMainCtrl extends BaseCtrl
  @inject 'app_analysis_dimReduction_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @app_analysis_dimReduction_dataService
    @DATA_TYPES = @dataService.getDataTypes()

    @title = 'Dimensionality Reduction module'
    @dataType = ''
    @transforming = off
    @transformation = ''
    @transformations = []
    @affinityMatrix = null

    @showresults = off
    @avgAccuracy = ''
    @accs = {}

    @dataPoints = null
    @means = null
    @assignments = null

    @$scope.$on 'dimReduction:updateDataPoints', (event, data) =>
#      @showresults = off if @showresults is on
      # safe enforce $scope.$digest to activate directive watchers
      @$timeout => @updateChartData(data)

    @$scope.$on 'dimReduction:updateDataType', (event, dataType) =>
      @dataType = dataType

  prettifyArrayOutput: (arr) ->
    if arr?
      arr = arr.map (x) -> x.toFixed 3
      '[' + arr.toString().split(',').join('; ') + ']'

  showResults: (accuracy) ->
    if Object.keys(accuracy).length isnt 0
      @avgAccuracy = accuracy.average.toFixed(2)
      delete accuracy.average
      @accs = accuracy
      @showresults = on

  updateChartData: (data) ->
    if data.dataPoints?
      if data.labels?
        @dataPoints = data.dataPoints.map((row, i) ->
          row.push(data.labels[i])
          return row
        )
      else
        @dataPoints = data.dataPoints

  finish: (results=null) ->
    @msgManager.broadcast 'dimReduction:done', results
    showResults results
