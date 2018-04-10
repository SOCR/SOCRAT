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
      state: null
      coords: null
      labels: null
      model: null
      c: null
    @newdata = 
      state: null
      coords: null

    @$scope.$on 'svm:updateDataPoints', (event, data) =>
      #console.log("GOT SIGNAL TO UPDATE DATA")

      if data.dataPoints != undefined
        @newdata.state = "scatter"
        @newdata.coords = data.dataPoints
        @graphingData = @newdata 
      #@sendGraphingData(data)

    @$scope.$on 'svm:startAlgorithm', (event, data) =>
      @selectedAlgorithm = data.model
      @$timeout => @sendAlgorithmData(data)

## need to listen or wait for algorithms to respond
      #@$timeout => @sendAlgorithmFinished(data)


  # organizeSend maybe not needed anymore

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

 # sendGraphingData: (data) ->
 #   if data?
 #     if data.dataPoints
 #       console.log(data)
 #       @graphingData.coords = data.dataPoints
  #    if data.labels
  #      console.log("LABELS")
  #      console.log(data)
  #      @graphingData.labels = data.labels
  #    console.log("broadcasting graphingData")
  #    console.log(@graphingData)
  #    @msgService.broadcast 'svm:sendScatterGraphing', @graphingData
      # not sure if sending data to directive is
      # with msgService.broadcast or just call function like
      # with service

  sendAlgorithmData: (data) ->
    if data?
      console.log("starting algorithm step")
      @graphingData.coords = data.dataPoints
      @graphingData.labels = data.labels
      console.log(@graphingData)
      @graphingData.state = "svm"
      @graphingData.model = data.model
      @algorithmsService.startAlgorithm(@graphingData)

  # figure out when to call this
  sendAlgorithmFinished: (data) ->
    if data?
      @graphingData.coords = data.dataPoints
      @graphingData.labels = data.labels
      # data.c or whatever the classification array is called
      @graphingData.c = data.c
      @graphingData.model = data.model
      @graphingData.state = "svm"
      @msgService.broadcast 'svm:sendAlgorithmGraphing', @graphingData
