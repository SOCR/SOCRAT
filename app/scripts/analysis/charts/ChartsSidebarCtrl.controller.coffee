'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ChartsSidebarCtrl extends BaseCtrl
  @inject '$q',
    '$stateParams',
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

#  _chartData = null
  @chartData: null
  @headers: null

  @selector1: {}
  @selector2: {}
  @selector3: {}
  @selector4: {}
  @stream: false

  @streamColors: [
    name: "blue"
    scheme: ["#045A8D", "#2B8CBE", "#74A9CF", "#A6BDDB", "#D0D1E6", "#F1EEF6"]
  ,
    name: "pink"
    scheme: ["#980043", "#DD1C77", "#DF65B0", "#C994C7", "#D4B9DA", "#F1EEF6"]
  ,
    name: "orange"
    scheme: ["#B30000", "#E34A33", "#FC8D59", "#FDBB84", "#FDD49E", "#FEF0D9"]
  ]

  @graphInfo:
    graph: ""
    x: ""
    y: ""
    z: ""

  @graphs: list.flat()
  @graphSelect: {}
  @labelVar: false
  @labelCheck: null

  @changeName: () ->
    @graphInfo.graph = @graphSelect.name

    if @graphSelect.name is "Stream Graph"
      @stream = true
    else
      @stream = false

    if @dataType is "NESTED"
      @graphInfo.x = "initiate"
      sendData.createGraph(@data, @graphInfo, {key: 0, value: "initiate"}, @dataType, @selector4.scheme)
    else
      sendData.createGraph(_chartData, @graphInfo, @headers, @dataType, @selector4.scheme)

  @changeVar: (selector,headers, ind) ->
    console.log @selector4.scheme
    #if scope.graphInfo.graph is one of the time series ones, test variables for time format and only allow those when ind = x
    #only allow numerical ones for ind = y or z
    for h in headers
      if selector.value is h.value then @graphInfo[ind] = parseFloat h.key
    sendData.createGraph(_chartData,@graphInfo,@headers, @dataType, @selector4.scheme)

