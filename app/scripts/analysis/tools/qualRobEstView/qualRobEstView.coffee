'use strict'

qualRobEstView = angular.module('app_analysis_qualRobEstView', [])

.factory('app_analysis_qualRobEstView_constructor', [
  'app_analysis_qualRobEstView_manager'
  (manager) ->
    (sb) ->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'qualRobEstView init invoked'

      destroy: () ->

      msgList: _msgList
])

.factory('app_analysis_qualRobEstView_manager', [
  () ->
    _sb = null

    _msgList =
      outgoing: ['add numbers']
      incoming: ['numbers added']
      scope: ['qualRobEstView']

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

.controller('qualRobEstViewSidebarCtrl', [
  'app_analysis_qualRobEstView_manager'
  '$scope'
  (ctrlMngr, $scope) ->
    console.log 'qualRobEstViewSidebarCtrl executed'

    $scope.realParams = '[1,1,1]'
    $scope.outcomeDim = '1'
    $scope.outcomeLevels = '3'
    $scope.numObserv = '1000'
    $scope.noiseLevel = '0.2'
    $scope.estParam = '0.5'

    sb = ctrlMngr.getSb()
    $scope.sumNumbers = () ->
      sb.publish
        msg: 'add numbers'
        data:
          a: $scope.outcomeDim
          b: $scope.outcomeLevels
        msgScope: ['qualRobEstView']
])

.controller('qualRobEstViewMainCtrl', [
  'app_analysis_qualRobEstView_manager'
  '$scope'
  (ctrlMngr, $scope) ->
    console.log 'qualRobEstViewMainCtrl executed'

    sb = ctrlMngr.getSb()
    sb.subscribe
      msg: 'numbers added'
      listener: (msg, data) ->
        $scope.sum = data
      msgScope: ['qualRobEstView']
])