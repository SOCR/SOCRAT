'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class SVMMainCtrl extends BaseCtrl
  @inject 'app_analysis_svm_dataService',
    'app_analysis_svm_msgService'
    'app_analysis_svm_algorithms'
    'app_analysis_svm_metrics'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @app_analysis_svm_dataService
    @DATA_TYPES = @dataService.getDataTypes()
    @msgService = @app_analysis_svm_msgService
    @algorithmsService = @app_analysis_svm_algorithms
    @algorithms = @algorithmsService.getNames()
    @title = 'SVM'
    @dataType = ''
    @dataPoints = null
    @customData = null
    @graphingData =
      state: "scatter"
      coords: null
      labels: null
      c: null

    @$scope.$on 'svm:updateDataPoints', (event, data) =>
      @selectedAlgorithm = data.model
      console.log("GOT SIGNAL TO UPDATE DATA")
      @$timeout => @sendGraphingData(data)

    @$scope.$on 'svm:startAlgorithm', (event, data) =>
      @$timeout => @sendAlgorithmData(data)


  # organizeSend: (data) ->
  #   if data? and data.dataPoints?
  #     @customData = data.dataPoints.map (point, i) ->
  #       if data.labels?
  #         label = data.labels[i]
  #       else
  #         label = 0
  #       point =
  #         x_c: point[0]
  #         y_c: point[1]
  #         c: label
  #       return point

  sendGraphingData: (data) ->
    if data?
      if data.dataPoints
        console.log(data)
        @graphingData.coords = data.dataPoints
      if data.labels
        console.log("LABELS")
        console.log(data)
        @graphingData.labels = data.labels
      @msgService.broadcast 'svm:sendScatterGraphing', @graphingData

  sendAlgorithmData: (data) ->
    if data?
      console.log("starting algorithm step")
      @graphingData.coords = data.dataFrame
      @graphingData.labels = data.labels
      console.log(@graphingData)
      @graphingData.state = "svm"
      @msgService.broadcast 'svm:sendAlgorithmGraphing', @graphingData
