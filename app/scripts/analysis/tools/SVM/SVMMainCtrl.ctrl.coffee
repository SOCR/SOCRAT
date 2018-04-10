'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class SVMMainCtrl extends BaseCtrl
  @inject 'app_analysis_svm_dataService',
    'app_analysis_svm_svmgraph'
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
    @svm = @app_analysis_svm_svmgraph
    @title = 'SVM'
    @dataType = ''
    @dataPoints = null
    @customData = null
    @graphingData =
      mesh_grid_points: null
      mesh_grid_labels: null
      features: null
      labels: null

    @newdata = 
      state: null
      mesh_grid_points: null
      mesh_grid_labels: null
      coords: null
      labels: null
      

    @$scope.$on 'svm:updateDataPoints', (event, data) =>
      #console.log("GOT SIGNAL TO UPDATE DATA")

      if data.dataPoints != undefined
        @newdata.state = "scatter"
        @newdata.coords = data.dataPoints
        @svm.drawSVM(@newdata)
        #console.log("graphingData updated")
        #@graphingData = @newdata 
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
      @graphingData = @algorithmsService.startAlgorithm(@selectedAlgorithm, data)
      @newdata.coords = @graphingData.features
      @newdata.mesh_grid_points = @graphingData.mesh_grid_points
      @newdata.mesh_grid_labels = @graphingData.mesh_grid_labels
      @newdata.state = 'svm'
      @newdata.labels = @graphingData.labels
      @svm.drawSVM(@newdata)

