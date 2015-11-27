'use strict'

charts = angular.module('app_analysis_charts', [])

.factory('app_analysis_charts_constructor', [
  'app_analysis_charts_manager'
  (manager)->
    (sb)->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'charts init called'

      destroy: () ->

      msgList: _msgList
])

.factory( 'app_analysis_charts_manager', [
  ()->
    _sb = null

    _msgList =
      outgoing: ['get table']
      incoming: ['take table']
      scope: ['charts']

    _setSb = (sb) ->
      _sb = sb

    _getSb = () ->
      _sb

    _getMsgList = () ->
      _msgList

    getSb: _getSb
    setSb: _setSb
    getMsgList: _getMsgList
])

.controller('mainchartsCtrl', [
    'app_analysis_charts_manager'
    '$scope'
    '$rootScope'
    (ctrlMngr,$scope,$rootScope) ->
      console.log 'mainchartsCtrl executed'


      $scope.print = () ->
        console.log $rootScope.dataT2
        console.log $rootScope.indexes
        x = $rootScope.indexes.x
        y = $rootScope.indexes.y
        console.log $rootScope.dataT2[x]
        console.log $rootScope.dataT2[y]

      graphDivs = (id,graph) ->
        console.log id, graph

      $rootScope.$on 'graphDiv', () =>
        graphDivs($rootScope.indexes.x,$rootScope.indexes.graph)
])

.directive('myTabs', () ->
  return {
  replace: false,
  transclude: true,
  template: '<li><a data-toggle = "tab" href="{{indexes.graph}}">{{indexes.graph}}</a></li>'
  }
)
.directive('tabBody', () ->
  return {
  template: '<div id="{{indexes.graph}}" class = "tab-pane fade" ><svg style="width:500px, height:500px"></svg></div>'
  }
)

.controller('sidechartsCtrl',[
    'app_analysis_charts_manager'
    '$scope'
    '$rootScope'
    '$stateParams'
    '$q'
    'app_analysis_charts_dataTransform'
    (ctrlMngr, $scope, $rootScope, $stateParams, $q, dataTransform) ->
      console.log 'sidechartsCtrl executed'
      $scope.selector1={};
      $scope.selector2={};
      $rootScope.indexes = {graph:"", x:"", y:""}

      $scope.graphs = [{name:'Bar Graph', value:0},{name:'Scatter Plot', value:1},{name:'Histogram', value:2},{name:'Bubble Chart', value:3},{name:'Pie Chart', value:4}]
      $scope.graphSelect = {}

      $scope.change = (selector,headers, ind) ->
        for h in headers
          if selector.value is h.value then $rootScope.indexes[ind] = parseFloat h.key

      $scope.createGraph = () ->
        $rootScope.$emit 'graphDiv'
        console.log $rootScope.indexes

      $scope.change1 = ()->
        $rootScope.indexes.graph = $scope.graphSelect.name


      sb = ctrlMngr.getSb()

      # deferred = $q.defer()

      token = sb.subscribe
        msg:'take table'
        msgScope:['charts']
        listener: (msg, _data) ->
          $rootScope.headers = d3.entries _data.header
          $scope.dataT = dataTransform.transpose(_data.data)
          $rootScope.dataT2 = dataTransform.transform($scope.dataT)
          console.log $rootScope.dataT2

      sb.publish
        msg:'get table'
        msgScope:['charts']
        callback: -> sb.unsubscribe token
        data:
          tableName: $stateParams.projectId + ':' + $stateParams.forkId


  ])

.factory('app_analysis_charts_dataTransform',[
  () ->
    _transpose = (data) ->
      data[0].map (col, i) -> data.map (row) -> row[i]

    _transform = (data) ->
      arr = []
      for col in data
        obj = {}
        for value, i in col
          obj[i] = value
        d3.entries obj




    transform: _transform
    transpose:_transpose
])

.directive 'd3Charts', [
  '$parse'
  ($parse) ->
    restrict: 'E'
    template: "<svg width='100%' height='600'></svg>"
    link: (scope, elem, attr) ->

      values = d3.range(1000).map(d3.random.bates(10))
      formatCount = d3.format(",.0f")
      margin = {top: 10, right: 30, bottom: 30, left: 30}
      width = 960 - margin.left - margin.right
      height = 500 - margin.top - margin.bottom
      x = d3.scale.linear().domain([0,1]).range([0,width])

      data = d3.layout.histogram().bins(x.ticks(20))(values)

      yMax = d3.max data, (d) ->
        return d.y
      xAxis = d3.svg.axis().scale(x).orient("bottom")
      y = d3.scale.linear().domain([0,yMax]).range([height, 0])
      rawSvg = elem.find("svg")[0]
      svg = d3.select(rawSvg)
      _graph = svg.append('g').attr("transform", "translate(" + margin.left + "," + margin.top + ")")

      _drawHist = (data) ->
        _graph.selectAll('.bar').remove()

        bar = _graph.selectAll('.bar').data(data).enter().append("g").attr("class", "bar").attr("transform",(d) => return "translate(" + x(d.x) + "," + y(d.y) + ")")
        bar.append('rect').attr('x', 1).attr('width', x(data[0].dx) - 1).attr 'height', (d) ->
          height - y(d.y)
        _graph.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis)

      _drawHist data
      console.log data
      console.log values
]

