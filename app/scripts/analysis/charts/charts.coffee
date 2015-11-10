'use strict'

charts = angular.module('app_analysis_charts', [])

charts.factory('app_analysis_charts_constructor', [
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

charts.factory( 'app_analysis_charts_manager', [
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

charts.controller('VarCtrl', [
    'app_analysis_charts_manager'
    '$scope'
    '$stateParams'
    '$q'
    (ctrlMngr, $scope, $stateParams, $q) ->
      console.log 'VarCtrl executed'

      sb = ctrlMngr.getSb()

     # deferred = $q.defer()

      token = sb.subscribe
        msg:'take table'
        msgScope:['charts']
        listener: (msg, data) ->
          $scope.data = data
          console.log data

      sb.publish
        msg:'get table'
        msgScope:['charts']
        callback: -> sb.unsubscribe token
        data:
          tableName: $stateParams.projectId + ':' + $stateParams.forkId
          #promise: deferred
])

charts.factory('app_analysis_charts_dataTransform',[
  '$scope'
  ($scope) ->
    transform = () ->

])
