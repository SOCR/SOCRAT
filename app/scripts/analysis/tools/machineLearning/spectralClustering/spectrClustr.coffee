'use strict'

spectrClustr = angular.module('app_analysis_spectrClustr', [])

.factory('app_analysis_spectrClustr_constructor', [
  'app_analysis_spectrClustr_manager'
  (manager) ->
    (sb) ->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'spectrClustr init invoked'

      destroy: () ->

      msgList: _msgList
])

.factory('app_analysis_spectrClustr_manager', [
  '$q'
  '$rootScope'
  '$stateParams'
  ($q, $rootScope, $stateParams) ->
    _sb = null

    _msgList =
      outgoing: ['get data']
      incoming: ['take data']
      scope: ['spectrClustr']

    _setSb = (sb) ->
      _sb = sb

    _getMsgList = () ->
      _msgList

    _getSupportedDataTypes = () ->
      if _sb
        _sb.getSupportedDataTypes()
      else
        false

    # wrapper function for controller communications
    _broadcast = (msg, data) ->
      $rootScope.$broadcast msg, data

    _publish = (msg, cb, data=null) ->
      if _sb and msg in _msgList.outgoing
        deferred = $q.defer()
        _sb.publish
          msg: msg
          msgScope: ['spectrClustr']
          callback: -> cb
          data:
            tableName: $stateParams.projectId + ':' + $stateParams.forkId
            promise: deferred
            data: data
      else false

    _subscribe = (msg, listener) ->
      if _sb and msg in _msgList.incoming
        token = _sb.subscribe
          msg: msg
          msgScope: ['spectrClustr']
          listener: listener
        token
      else false

    _unsubscribe = (token) ->
      if _sb
        _sb.unsubscribe token
      else false

    setSb: _setSb
    getMsgList: _getMsgList
    publish: _publish
    subscribe: _subscribe
    unsubscribe: _unsubscribe
    broadcast: _broadcast
    getSupportedDataTypes: _getSupportedDataTypes
])

.factory('app_analysis_spectrClustr_dataService', [
  'app_analysis_spectrClustr_manager'
  '$q'
  (msgManager, $q) ->

    getData = () ->
      deferred = $q.defer()
      token = msgManager.subscribe 'take data', (msg, data) -> deferred.resolve data
      msgManager.publish 'get data', -> msgManager.unsubscribe token
      deferred.promise

    getData: getData
])

.controller('spectrClustrMainCtrl', [
  'app_analysis_spectrClustr_dataService'
  'app_analysis_spectrClustr_calculator'
  '$scope'
  '$timeout'
  (dataService, spectrClustr, $scope, $timeout) ->
    console.log 'spectrClustrMainCtrl executed'

    dataService.getData().then (data) ->
      console.log data
])

.controller('spectrClustrSidebarCtrl', [
  'app_analysis_spectrClustr_manager'
  'app_analysis_spectrClustr_calculator'
  '$scope'
  '$stateParams'
  '$q'
  '$timeout'
  (msgManager, spectrClustr, $scope, $stateParams, $q, $timeout) ->
    console.log 'spectrClustrSidebarCtrl executed'
])

.factory('app_analysis_spectrClustr_calculator', [
  () ->
    _calculate = ->

    calculate: _calculate
])

.directive 'appSpectrClustr', [
  '$parse'
  ($parse) ->
    restrict: 'E'
    template: "<svg width='100%' height='600'></svg>"
    link: (scope, elem, attr) ->

      console.log 'appSpectrClustr directive linked'
]
