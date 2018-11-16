'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ClassificationMainCtrl extends BaseCtrl
  @inject 'app_analysis_classification_dataService',
    'app_analysis_classification_classificationgraph'
    'app_analysis_classification_msgService'
    'app_analysis_classification_algorithms'
    'app_analysis_classification_metrics'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @app_analysis_classification_dataService
    @DATA_TYPES = @dataService.getDataTypes()
    @msgService = @app_analysis_classification_msgService
    @algorithmsService = @app_analysis_classification_algorithms
    @algorithms = @algorithmsService.getNames()
    @graph = @app_analysis_classification_classificationgraph
    @title = 'Machine Learning Classification'
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


    @$scope.$on 'classification:updateDataPoints', (event, data) =>
      #console.log("GOT SIGNAL TO UPDATE DATA")

      if data.dataPoints != undefined
        @newdata.state = "scatter"
        @newdata.coords = data.dataPoints
        @newdata.legend = data.legend
        @newdata.labels = data.labels
        @newdata.xCol = data.xCol
        @newdata.yCol = data.yCol


        console.log @newdata

        @graph.drawSVM(@newdata)
        #console.log("graphingData updated")
        #@graphingData = @newdata
      #@sendGraphingData(data)

    @$scope.$on 'classification:startAlgorithm', (event, data) =>
      @selectedAlgorithm = data.model
      @$timeout => @sendAlgorithmData(data)


    @$scope.$on 'classification:resetGrid', (event, data) =>
      console.log("reset button reaches MainCtrl")
      @newdata.state = "scatter"
      @graph.drawSVM(@newdata)


  sendAlgorithmData: (data) ->
    if data?
      console.log("starting algorithm step")
      @graphingData = @algorithmsService.trainingByName(@selectedAlgorithm, data)
      @newdata.coords = @graphingData.features
      @newdata.mesh_grid_points = @graphingData.mesh_grid_points
      @newdata.mesh_grid_labels = @graphingData.mesh_grid_labels
      @newdata.state = 'svm'
      @newdata.xCol = data.xCol
      @newdata.yCol = data.yCol
      # @newdata.labels = @graphingData.labels
      @graph.drawSVM(@newdata)

  sendReset: () ->
    console.log("reset button reaches MainCtrl")
    @newdata.state = "scatter"
    @graph.drawSVM(@newdata)
