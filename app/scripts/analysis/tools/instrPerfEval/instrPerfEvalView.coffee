'use strict'

instrPerfEvalView = angular.module('app_analysis_instrPerfEvalView', [])

.factory('app_analysis_instrPerfEvalView_constructor', [
  'app_analysis_instrPerfEvalView_manager'
  (manager) ->
    (sb) ->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'instrPerfEvalView init invoked'

      destroy: () ->

      msgList: _msgList
])

.factory('app_analysis_instrPerfEvalView_manager', [
  () ->
    _sb = null

    _msgList =
      outgoing: ['calculate', 'get table']
      incoming: ['calculated', 'take table']
      scope: ['instrPerfEvalView']

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

.controller('instrPerfEvalViewSidebarCtrl', [
  'app_analysis_instrPerfEvalView_manager'
  '$scope'
  '$stateParams'
  '$q'
  (ctrlMngr, $scope, $stateParams, $q) ->
    console.log 'instrPerfEvalViewSidebarCtrl executed'

    $scope.nCols = '5'
    $scope.nRows = '5'

    deferred = $q.defer()

    sb = ctrlMngr.getSb()
    $scope.calculate = ->

      sb.publish
        msg: 'get table'
        data:
          tableName: $stateParams.projectId + ':' + $stateParams.forkId
          promise: deferred
        msgScope: ['instrPerfEvalView']

#      sb.publish
#        msg: 'calculate'
#        data:
#          a: $scope.nCols
#          b: $scope.nRows
#        msgScope: ['instrPerfEvalView']
])

.controller('instrPerfEvalViewMainCtrl', [
  'app_analysis_instrPerfEvalView_manager'
  '$scope'
  (ctrlMngr, $scope) ->
    console.log 'instrPerfEvalViewMainCtrl executed'

    sb = ctrlMngr.getSb()

    sb.subscribe
      msg: 'take table'
      listener: (msg, data) ->
        console.log data
        $scope.outputStats = data
      msgScope: ['instrPerfEvalView']
#    sb.subscribe
#      msg: 'calculated'
#      listener: (msg, data) ->
#        $scope.outputStats = data
#      msgScope: ['instrPerfEvalView']
])