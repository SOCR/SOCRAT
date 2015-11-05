'use strict'

kMeans = angular.module('app_analysis_kMeans', [])

.factory('app_analysis_kMeans_constructor', [
    'app_analysis_kMeans_manager'
    (manager) ->
      (sb) ->

        manager.setSb sb unless !sb?
        _msgList = manager.getMsgList()

        init: (opt) ->
          console.log 'kMeans init invoked'

        destroy: () ->

        msgList: _msgList
  ])

.factory('app_analysis_kMeans_manager', [
    () ->
      _sb = null

      _msgList =
        outgoing: ['get table']
        incoming: ['take table']
        scope: ['kMeans']

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

.controller('kMeansMainCtrl', [
    'app_analysis_kMeans_manager'
    'app_analysis_kMeans_calculator'
    '$scope'
    (ctrlMngr, calculator, $scope) ->
      console.log 'kMeansViewMainCtrl executed'

      prettifyArrayOutput = (arr) ->
        if arr?
          arr = arr.map (x) -> x.toFixed 3
          '[' + arr.toString().split(',').join('; ') + ']'
  ])

.controller('kMeansSidebarCtrl', [
    'app_analysis_kMeans_manager'
    'app_analysis_kMeans_calculator'
    '$scope'
    '$stateParams'
    '$q'
    (ctrlMngr, alphaCalculator, $scope, $stateParams, $q) ->
      console.log 'kMeansViewSidebarCtrl executed'

      sb = ctrlMngr.getSb()

      $scope.nCols = '5'
      $scope.nRows = '5'

      deferred = $q.defer()

      $scope.confLevel = 0.95

      # subscribe for incoming message with data
      token = sb.subscribe
        msg: 'take table'
        msgScope: ['kMeans']
        listener: (msg, data) ->
          _data = data
          $scope.nRows = _data.data?.length
          $scope.nCols = _data.data[0]?.length
          console.log data
          alphaCalculator.calculate data, $scope.confLevel

      sb.publish
        msg: 'get table'
        msgScope: ['kMeans']
        callback: -> sb.unsubscribe token
        data:
          tableName: $stateParams.projectId + ':' + $stateParams.forkId
          promise: deferred
  ])

.factory('app_analysis_kMeans_calculator', [
    () ->

      _data = []

      _calculate = (obj, confLevel) ->
        _matrix = jStat obj.data
        _matrix = jStat jStat.map _matrix, Number


        _data =
          result: _matrix

      calculate: _calculate
  ])