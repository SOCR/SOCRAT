#'use strict'
#
#spectrClustr = angular.module('app_analysis_spectrClustr', [])
#
#.factory('app_analysis_spectrClustr_constructor', [
#  'app_analysis_spectrClustr_manager'
#  (manager) ->
#    (sb) ->
#
#      manager.setSb sb unless !sb?
#      _msgList = manager.getMsgList()
#
#      init: (opt) ->
#        console.log 'spectrClustr init invoked'
#
#      destroy: () ->
#
#      msgList: _msgList
#])
#
#.factory('app_analysis_spectrClustr_manager', [
#  '$q'
#  '$rootScope'
#  '$stateParams'
#  ($q, $rootScope, $stateParams) ->
#    _sb = null
#
#    _msgList =
#      outgoing: ['get data']
#      incoming: ['take data']
#      scope: ['spectrClustr']
#
#    _setSb = (sb) ->
#      _sb = sb
#
#    _getMsgList = () ->
#      _msgList
#
#    _getSupportedDataTypes = () ->
#      if _sb
#        _sb.getSupportedDataTypes()
#      else
#        false
#
#    # wrapper function for controller communications
#    _broadcast = (msg, data) ->
#      $rootScope.$broadcast msg, data
#
#    _publish = (msg, cb, data=null) ->
#      if _sb and msg in _msgList.outgoing
#        deferred = $q.defer()
#        _sb.publish
#          msg: msg
#          msgScope: ['spectrClustr']
#          callback: -> cb
#          data:
#            tableName: $stateParams.projectId + ':' + $stateParams.forkId
#            promise: deferred
#            data: data
#      else false
#
#    _subscribe = (msg, listener) ->
#      if _sb and msg in _msgList.incoming
#        token = _sb.subscribe
#          msg: msg
#          msgScope: ['spectrClustr']
#          listener: listener
#        token
#      else false
#
#    _unsubscribe = (token) ->
#      if _sb
#        _sb.unsubscribe token
#      else false
#
#    setSb: _setSb
#    getMsgList: _getMsgList
#    publish: _publish
#    subscribe: _subscribe
#    unsubscribe: _unsubscribe
#    broadcast: _broadcast
#    getSupportedDataTypes: _getSupportedDataTypes
#])
#
#.factory('app_analysis_spectrClustr_dataService', [
#  'app_analysis_spectrClustr_manager'
#  '$q'
#  (msgManager, $q) ->
#
#    _getData = ->
#      deferred = $q.defer()
#      token = msgManager.subscribe 'take data', (msg, data) -> deferred.resolve data
#      msgManager.publish 'get data', -> msgManager.unsubscribe token
#      deferred.promise
#
#    _getDataTypes = ->
#      msgManager.getSupportedDataTypes()
#
#    getData: _getData
#    getDataTypes: _getDataTypes
#])
#
#.controller('spectrClustrMainCtrl', [
#  'app_analysis_spectrClustr_dataService'
#  'app_analysis_spectrClustr_calculator'
#  'app_analysis_spectrClustr_dataTrasformer'
#  '$scope'
#  '$timeout'
#  (dataService, spectrClustr, dataTransformer, $scope, $timeout) ->
#    console.log 'spectrClustrMainCtrl executed'
#
#    $scope.dataType = ''
#    $scope.transforming = off
#    $scope.transformation = ''
#    $scope.transformations = []
#    $scope.affinityMatrix = null
#    $scope.DATA_TYPES = dataService.getDataTypes()
#
#    arrayEqual = (a, b) ->
#      a.length is b.length and a.every (elem, i) -> elem is b[i]
#
#    # check if data matrix symmetric
#    isDataAffinityMatrix = (data) ->
#      arrayEqual d3.merge(data), d3.merge(d3.transpose data)
#
#    convertToAffinityMatrix = (data) ->
#      if isDataaffinityMatrix data
#        $scope.affinityMatrix = data
#      else
#        $scope.transformations = dataTransformer.getTransfomations()
#        $scope.transformation = $scope.transformations[0]
#        $scope.transform = ->
#          $scope.transforming = on
#          $scope.affinityMatrix = dataTransformer.transform(data, $scope.transformation)
#          $scope.transforming = off
#
#    dataService.getData().then (dataFrame) ->
#      $scope.dataType = dataFrame.dataType
#      if $scope.dataType is $scope.DATA_TYPES.FLAT
#        convertToAffinityMatrix dataFrame.data
#])
#
#.controller('spectrClustrSidebarCtrl', [
#  'app_analysis_spectrClustr_manager'
#  'app_analysis_spectrClustr_calculator'
#  '$scope'
#  '$stateParams'
#  '$q'
#  '$timeout'
#  (msgManager, spectrClustr, $scope, $stateParams, $q, $timeout) ->
#    console.log 'spectrClustrSidebarCtrl executed'
#
#      DATA_TYPES = msgManager.getSupportedDataTypes()
#
#      DEFAULT_CONTROL_VALUES =
#        labelson: true
#        wholedataseton: true
#        accuracyon: false
#
#      # set initial values for sidebar controls
#      initSidebarControls = (initControlValues) ->
#        params = spectrClustr.getParameters()
#        $scope.ks = [params.minK..params.maxK]
#        $scope.affinities = params.affinities
#        $scope.gamma: gamma
#        $scope.sigma: sigma
#        $scope.nNeighbors: nNeighbors
#
#        $scope.cols = []
#        $scope.clustering = on
#        $scope.running = 'hidden'
#        $scope.uniqueLabels =
#          labelCol: null
#          num: null
#
#        $scope.k = $scope.ks[0]
#        $scope.initMethod = $scope.affinities[0]
#        $scope.labelson = initControlValues.labelson
#        $scope.wholedataseton = initControlValues.wholedataseton
#        $scope.accuracyon = initControlValues.accuracyon
#
#      initSidebarControls DEFAULT_CONTROL_VALUES
#])
#
#.factory('app_analysis_spectrClustr_dataTrasformer', [
#  () ->
#
#    EPS = 1e-6
#    BETA = 1
#
#    squaredEuclideanDistance = (v1, v2) ->
#      total = 0
#      for i in [0..v1.length - 1]
#        total += Math.pow(v2[i] - v1[i], 2)
#      total
##      Math.sqrt(total)
##
##    cosineDistance = (v1, v2) ->
##      num = (v1.map (e, idx) -> e * v2[idx]).reduce (t, s) -> t + s
##      den = Math.sqrt(v1.map((e) -> e*e).reduce (t, s) -> t + s) * Math.sqrt(v2.map((e) -> e*e).reduce (t, s) -> t + s)
##      num / den
#
#    # Ng, Andrew Y., Michael I. Jordan, and Yair Weiss. "On spectral clustering: Analysis and an algorithm."
#    #  Advances in neural information processing systems 2 (2002): 849-856.
#    ngJordanWeiss = (data) ->
#      result = (0 for r1 in data for r2 in data)
#      for row, i in data
#        for nextRow, j in data[i..]
#          value = Math.exp(-1 * Math.pow(squaredEuclideanDistance(row, nextRow), 2))
#          result[i][i + j] = result[i + j][i] =
#      result
#
#    transform: _transform
#    getTransfomations: _getTransfomations
#])
#
#.factory('app_analysis_spectrClustr_calculator', [
#  () ->
#
#    graph = null
#    computeAcc = off
#    clusterWholeDataset = on
#    maxIter = 20
#    eps = 1e-6
#    minK = 2
#    maxK = 10
#    affinity = ['RBF', 'kNN']
#    # advanced parameters for affinity methods
#    gamma = 1  # multiplier for RBF affinity
#    sigma = off  #  normalizing by STD for RBF affinity
#    nNeighbors = 10  # for kNN affinity
#
#    _getParameters = ->
#      minK: minK
#      maxK: maxK
#      distances: distances
#      affinities: affinity
#      gamma: gamma
#      sigma: sigma
#      nNeighbors: nNeighbors
#
#
#    _calculate = ->
#
#    calculate: _calculate
#])
#
#.directive 'appSpectrClustr', [
#  '$parse'
#  ($parse) ->
#    restrict: 'E'
#    template: "<svg width='100%' height='600'></svg>"
#    link: (scope, elem, attr) ->
#
#      console.log 'appSpectrClustr directive linked'
#]
