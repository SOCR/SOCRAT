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

])

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
      $scope.change = (selector,headers, ind) ->
        for h in headers
          if selector.value is h.value then $rootScope.indexes[ind] = parseFloat h.key

      sb = ctrlMngr.getSb()

      # deferred = $q.defer()

      token = sb.subscribe
        msg:'take table'
        msgScope:['charts']
        listener: (msg, _data) ->
          $scope.headers = d3.entries _data.header
          $scope.dataT = dataTransform.transpose(_data.data)
          $rootScope.dataT2 = dataTransform.transform($scope.dataT)
          console.log $rootScope.dataT2

      sb.publish
        msg:'get table'
        msgScope:['charts']
        callback: -> sb.unsubscribe token
        data:
          tableName: $stateParams.projectId + ':' + $stateParams.forkId

      $scope.graphs = [{name:'Bar Graph', value:0},{name:'Scatter Plot', value:1},{name:'Histogram', value:2},{name:'Bubble Chart', value:3},{name:'Pie Chart', value:4}]
      $scope.graphSelect = {}

      $scope.change1 = ()->
        console.log $scope.graphSelect
        $rootScope.indexes.graph = $scope.graphSelect.name

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


