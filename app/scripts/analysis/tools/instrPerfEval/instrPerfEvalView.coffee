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
      outgoing: ['calculate']
      incoming: ['calculated']
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
  (ctrlMngr, $scope) ->
    console.log 'instrPerfEvalViewSidebarCtrl executed'

    $scope.nCols = '5'
    $scope.nRows = '5'

    sb = ctrlMngr.getSb()
    $scope.calculate = () ->
      sb.publish
        msg: 'calculate'
        data:
          a: $scope.nCols
          b: $scope.nRows
        msgScope: ['instrPerfEvalView']
])

.controller('instrPerfEvalViewMainCtrl', [
  'app_analysis_instrPerfEvalView_manager'
  '$scope'
  (ctrlMngr, $scope) ->
    console.log 'instrPerfEvalViewMainCtrl executed'

    sb = ctrlMngr.getSb()
    sb.subscribe
      msg: 'calculate'
      listener: (msg, data) ->
        $scope.outputStats = data
      msgScope: ['instrPerfEvalView']
])