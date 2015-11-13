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
    '$stateParams'
    '$q'
    'app_analysis_charts_dataTransform'
    (ctrlMngr, $scope, $stateParams, $q, dataTransform) ->
      console.log 'VarCtrl executed'

      sb = ctrlMngr.getSb()

     # deferred = $q.defer()

      token = sb.subscribe
        msg:'take table'
        msgScope:['charts']
        listener: (msg, _data) ->
          $scope.data = _data
          console.log _data
          $scope.varNames = {variables: _data.header, selectedVar: null}
          $scope.dataT = dataTransform.transpose(_data.data)
          console.log $scope.dataT
          console.log dataTransform.transform($scope.dataT)
          console.log $scope.varNames.variables
      sb.publish
        msg:'get table'
        msgScope:['charts']
        callback: -> sb.unsubscribe token
        data:
          tableName: $stateParams.projectId + ':' + $stateParams.forkId
          #promise: deferred
])

.factory('app_analysis_charts_dataTransform',[
  () ->
    _transpose = (data) ->
      data[0].map (col, i) -> data.map (row) -> row[i]

    _transform = (data) ->
      arr = []
      for col in data
        #console.log col
        obj = {}
        for value, i in col
          obj[i] = value
        d3.entries obj

    transform: _transform
    transpose:_transpose
])
