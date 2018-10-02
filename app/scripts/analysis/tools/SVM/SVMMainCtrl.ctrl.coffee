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
        @newdata.legend = data.legend
        @newdata.labels = data.labels

        @svm.drawSVM(@newdata)
        #console.log("graphingData updated")
        #@graphingData = @newdata
      #@sendGraphingData(data)

    @$scope.$on 'svm:startAlgorithm', (event, data) =>
      @selectedAlgorithm = data.model
      @$timeout => @sendAlgorithmData(data)

  sendAlgorithmData: (data) ->
    if data?
      console.log("starting algorithm step")
      @graphingData = @algorithmsService.trainingByName(@selectedAlgorithm, data)
      @newdata.coords = @graphingData.features
      @newdata.mesh_grid_points = @graphingData.mesh_grid_points
      @newdata.mesh_grid_labels = @graphingData.mesh_grid_labels
      @newdata.state = 'svm'
      @newdata.labels = @graphingData.labels
      @svm.drawSVM(@newdata)

  sendReset: () ->
    console.log("reset button reaches MainCtrl")
    @newdata.state = "scatter"
    @svm.drawSVM(@newdata)
