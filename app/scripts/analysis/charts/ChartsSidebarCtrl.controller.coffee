'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ChartsSidebarCtrl extends BaseCtrl
  @inject   '$scope',
    '$rootScope',
    '$stateParams',
    '$q',
    'app_analysis_charts_dataTransform',
    'app_analysis_charts_list',
    'app_analysis_charts_sendData',
    'app_analysis_charts_checkTime',
    'app_analysis_charts_msgService'

  initialize: ->
    @eventManager = @app_analysis_charts_msgService
    @dataTransform = @app_analysis_charts_dataTransform
    @list = @app_analysis_charts_list
    @sendData = @app_analysis_charts_sendData
    @checkTime = @app_analysis_charts_checkTime


  _chartData = null
  _headers = null

  @$scope.selector1 = {}
  @$scope.selector2 = {}
  @$scope.selector3 = {}
  @$scope.selector4 = {}
  @$scope.stream = false

  @$scope.streamColors = [
    name: "blue"
    scheme: ["#045A8D", "#2B8CBE", "#74A9CF", "#A6BDDB", "#D0D1E6", "#F1EEF6"]
  ,
    name: "pink"
    scheme: ["#980043", "#DD1C77", "#DF65B0", "#C994C7", "#D4B9DA", "#F1EEF6"]
  ,
    name: "orange"
    scheme: ["#B30000", "#E34A33", "#FC8D59", "#FDBB84", "#FDD49E", "#FEF0D9"]
  ]

  @$scope.graphInfo =
  graph: ""
  x: ""
  y: ""
  z: ""

  @$scope.graphs = list.flat()
  @$scope.graphSelect = {}
  @$scope.labelVar = false
  @$scope.labelCheck = null

  @$scope.changeName = () ->
    @$scope.graphInfo.graph = @$scope.graphSelect.name

    if @$scope.graphSelect.name is "Stream Graph"
      @$scope.stream = true
    else
      @$scope.stream = false

    if @$scope.dataType is "NESTED"
      @$scope.graphInfo.x = "initiate"
      sendData.createGraph(@$scope.data, @$scope.graphInfo, {key: 0, value: "initiate"}, @$rootScope, @$scope.dataType, @$scope.selector4.scheme)
    else
      sendData.createGraph(_chartData, @$scope.graphInfo, _headers, @$rootScope, @$scope.dataType, @$scope.selector4.scheme)

  @$scope.changeVar = (selector,headers, ind) ->
    console.log @$scope.selector4.scheme
    #if scope.graphInfo.graph is one of the time series ones, test variables for time format and only allow those when ind = x
    #only allow numerical ones for ind = y or z
    for h in headers
      if selector.value is h.value then @$scope.graphInfo[ind] = parseFloat h.key
    sendData.createGraph(_chartData,@$scope.graphInfo,_headers, @$rootScope, @$scope.dataType, @$scope.selector4.scheme)

