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
  '$rootScope'
  ($rootScope) ->
    _sb = null

    _msgList =
      outgoing: ['get data']
      incoming: ['take data']
      scope: ['spectrClustr']

    _setSb = (sb) ->
      _sb = sb

    _getSb = () ->
      _sb

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

    getSb: _getSb
    setSb: _setSb
    getMsgList: _getMsgList
    broadcast: _broadcast
    getSupportedDataTypes: _getSupportedDataTypes
])

.controller('spectrClustrMainCtrl', [
  'app_analysis_spectrClustr_manager'
  'app_analysis_spectrClustr_calculator'
  '$scope'
  '$timeout'
  (msgManager, spectrClustr, $scope, $timeout) ->
    console.log 'spectrClustrMainCtrl executed'
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

])

.directive 'appSpectrClustr', [
  '$parse'
  ($parse) ->
    restrict: 'E'
    template: "<svg width='100%' height='600'></svg>"
    link: (scope, elem, attr) ->

      console.log 'appSpectrClustr directive linked'
]
