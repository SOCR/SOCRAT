'use strict'

qualRobEstView = angular.module('app_qualRobEstView', [])

.factory('qualRobEstView', [
  'qualRobEstView_manager'
  (ctrlMngr) ->
    (sb) ->
      ctrlMngr.setSb sb unless !sb?

      _msgList =
        outgoing: ['add numbers']
        incoming: ['numbers added']
        scope: ['qualRobEstView']

      init: (opt) ->
        console.log 'qualRobEstView init invoked'

      destroy: () ->

      msgList: _msgList
])

.factory('qualRobEstView_manager', [
  () ->
    _sb = null

    _setSb = (sb) ->
      _sb = sb

    _getSb = () ->
      _sb

    getSb: _getSb
    setSb: _setSb
])

.controller('qualRobEstViewSidebarCtrl', [
  'qualRobEstView_manager'
  '$scope'
  (ctrlMngr, $scope) ->
    console.log 'qualRobEstViewSidebarCtrl executed'

    $scope.realParams = '[1,1,1]'
    $scope.outcomeDim = '1'
    $scope.outcomeLevels = '3'
    $scope.numObserv = '1000'
    $scope.noiseLevel = '0.2'
    $scope.estParam = '0.5'

    console.log ctrlMngr
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
  'qualRobEstView_manager'
  '$scope'
  (ctrlMngr, $scope) ->
    console.log 'qualRobEstViewMainCtrl executed'

    sb = ctrlMngr.getSb()
    sb.subscribe
      msg: 'numbers added'
      listener: (msg, data) ->
        console.log 'GOT RESULT'
        $scope.sum = data
      msgScope: ['qualRobEstView']
])