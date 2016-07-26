#'use strict'
#
#module.exports = angular.module('app_analysis_wrangleData', [])
#
#.config([
#    () ->
#      console.log 'config block of wrangleData'
#])
#
#.factory('app_analysis_wrangleData_constructor', [
#  'app_analysis_wrangleData_manager'
#  (manager) ->
#    (sb) ->
#
#      manager.setSb sb unless !sb?
#      _msgList = manager.getMsgList()
#
#      init: (opt) ->
#        console.log 'wrangleData init invoked'
#
#      destroy: () ->
#
#      msgList: _msgList
#])
#
#.factory('app_analysis_wrangleData_manager', [
#  '$rootScope'
#  ($rootScope) ->
#    _sb = null
#
#    _msgList =
#      outgoing: ['save data', 'get data']
#      incoming: ['wrangle data']
#      scope: ['wrangleData']
#
#    _setSb = (sb) ->
#      _sb = sb
#
#    _getSb = () ->
#      _sb
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
#    getSb: _getSb
#    setSb: _setSb
#    getMsgList: _getMsgList
#    broadcast: _broadcast
#    getSupportedDataTypes: _getSupportedDataTypes
#])
#
#.factory('app_analysis_wrangleData_dataRetriever', [
#    '$q'
#    'app_analysis_wrangleData_manager'
#    'app_analysis_wrangleData_dataAdaptor'
#    ($q, manager, dataAdaptor) ->
#
#      _data = null
#
#      _sb = manager.getSb()
#
#      _getData = () ->
#
#        deferred = $q.defer()
#
#        token = _sb.subscribe
#          msg: 'wrangle data'
#          msgScope: ['wrangleData']
#          listener: (msg, data) ->
#            _data = data
#
#        _sb.publish
#          msg: 'get data'
#          msgScope: ['wrangleData']
#          callback: -> _sb.unsubscribe token
#          data:
##            tableName: $stateParams.projectId + ':' + $stateParams.forkId
#            tableName: 'undefined:undefined'
#            promise: deferred
#
#        _data
#
#      getData: _getData
#  ])
#
#.factory('app_analysis_wrangleData_dataAdaptor', [
#  'app_analysis_wrangleData_manager'
#  (eventManager) ->
#
#    DATA_TYPES = eventManager.getSupportedDataTypes()
#
#    _toCsvString = (dataFrame) ->
#
#      csv = dataFrame.header.toString() + '\n'
#
#      csv += row.toString() + '\n' for row in dataFrame.data
#
#      # remove last carriage return to prevent adding empty row
#      csv = csv.slice 0, -1
#
#    _toDvTable = (dataFrame) ->
#
#      table = []
#
#      # transpose array to make it column oriented
#      _data = ((row[i] for row in dataFrame.data) for i in [0...dataFrame.nCols])
#
#      for i, col of _data
#        table.push
#          name: dataFrame.header[i]
#          values: col
#          type: 'symbolic'
#
#      table
#
#    _toDataFrame = (table) ->
#
#      # remove last empty row
#      row.pop() for row in table
#
#      _nRows = table[0].length
#      _nCols = table.length
#
#      # transpose array to make it row oriented
#      _data = ((col[i] for col in table) for i in [0..._nRows])
#
#      _header = (col.name for col in table)
#      _types = (col.type for col in table)
#
#      dataFrame =
#        data: _data
#        header: _header
#        types: _types
#        nRows: _nRows
#        nCols: _nCols
#        dataType: DATA_TYPES.FLAT
#
#    toDvTable: _toDvTable
#    toDataFrame: _toDataFrame
#    toCsvString: _toCsvString
#])
#
#.factory('app_analysis_wrangleData_wrangler', [
#    '$q'
#    '$timeout'
#    '$stateParams'
#    '$rootScope'
#    'app_analysis_wrangleData_manager'
#    'app_analysis_wrangleData_dataRetriever'
#    'app_analysis_wrangleData_dataAdaptor'
#    ($q, $timeout, $stateParams, $rootScope, manager, dataRetriever, dataAdaptor) ->
#
#      _initial_transforms = []
#      _table = []
#      _csvData = []
#
#      DATA_TYPES = manager.getSupportedDataTypes()
#
#      _init = () ->
#        data = dataRetriever.getData()
#        if data.dataType is DATA_TYPES.FLAT
#          _csvData = dataAdaptor.toCsvString data
#          true
#        else
#          false
#
#      _start = (viewContainers) ->
#        _table = _wrangle(viewContainers)
#
#      _wrangle = (viewContainers) ->
#        # TODO: abstract from using dv directly #SOCRFW-143
#        table = dv.table _csvData
#
#        _initial_transforms = dw.raw_inference(_csvData).transforms
#
#        dw.wrangler
#          table: table
#          initial_transforms: _initial_transforms
#          tableContainer: viewContainers.tableContainer
#          transformContainer: viewContainers.transformContainer
#          previewContainer: viewContainers.previewContainer
#          dashboardContainer: viewContainers.dashboardContainer
#
#        table
#
#      _saveDataToDb = ->
#
#        clearTimeout _timer
#        _sb = manager.getSb()
#        deferred = $q.defer()
#
#        dataFrame = dataAdaptor.toDataFrame _table
#
#        _sb.publish
#          msg: 'save data'
#          data:
#            dataFrame: dataFrame
#            tableName: $stateParams.projectId + ':' + $stateParams.forkId
#            promise: deferred
#          msgScope: ['wrangleData']
#          callback: ->
#            console.log 'wrangled data saved to db'
#
#        _timer =  $timeout ( ->
#
#          msgEnding = if dataFrame.dataType is DATA_TYPES.FLAT then ' as 2D data table' else ' as hierarchical object'
#
#          $rootScope.$broadcast 'app:push notification',
#            initial:
#              msg: 'Data is being saved in the database...'
#              type: 'alert-info'
#            success:
#              msg: 'Successfully loaded data into database' + msgEnding
#              type: 'alert-success'
#            failure:
#              msg: 'Error in Database'
#              type: 'alert-error'
#            promise:deferred.promise
#
#        ), 1000
#        true
#
#      init: _init
#      start: _start
#      saveData: _saveDataToDb
#  ])
#
#.controller('wrangleDataSidebarCtrl', [
#    '$scope'
#    'app_analysis_wrangleData_manager'
#    ($scope, wrangleDataEventMngr) ->
#      console.log 'wrangleDataSidebarCtrl executed'
#
#      # hide sidebar
#      $scope.$parent.toggle()
#      # bring sidebar back on exit
#      $scope.$on 'wrangler:done', (event, results) ->
#        $scope.$parent.toggle()
#  ])
#
#.controller('wrangleDataMainCtrl', [
#  '$scope'
#  '$rootScope'
#  'app_analysis_wrangleData_wrangler'
#  'app_analysis_wrangleData_manager'
#  ($scope, $rootScope, wrangler, msgManager) ->
#
#    DATA_TYPES = msgManager.getSupportedDataTypes()
#    $scope.DATA_TYPES = DATA_TYPES
#    $scope.dataType = ''
#
#    data = wrangler.init()
#    if data
#      $scope.dataType = DATA_TYPES.FLAT
#
#      # TODO: isolate dw from global scope
#      w = dw.wrangle()
#
#    # listen to state change and save data when exiting Wrangle Data
#    stateListener = $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
#      if fromState.name? and fromState.name is 'wrangleData'
#        if $scope.dataType is DATA_TYPES.FLAT
#          # save data to db on exit from wrangler
#          wrangler.saveData()
#        # signal to show sidebar
#        msgManager.broadcast 'wrangler:done'
#        # unsubscribe
#        stateListener()
#
#    console.log 'wrangleDataMainCtrl executed'
#])
#
#.directive 'datawrangler', [
#  '$exceptionHandler'
#  'app_analysis_wrangleData_wrangler'
#  'app_analysis_wrangleData_manager'
#  ($exceptionHandler, wrangler, msgManager) ->
#
#    restrict: 'E'
#    transclude: true
#    templateUrl: '../partials/analysis/wrangleData/wrangler.html'
#    replace: true # replace the directive element with the output of the template
#
#    # the controller for the directive
#    controller: ($scope) ->
#
#    # The link method does the work of setting the directive
#    #  up, things like bindings, jquery calls, etc are done in here
#    link: (scope, elem, attr) ->
#      # useful to identify which handsontable instance to update
#      scope.purpose = attr.purpose
#
#      DATA_TYPES = msgManager.getSupportedDataTypes()
#
#      # check if received dataset is flat
#      if scope.dataType? and scope.dataType is DATA_TYPES.FLAT
#        myLayout = $('#dt_example').layout
#          north:
#            spacing_open: 0
#            resizable: false
#            slidable: false
#            fxName: 'none'
#          south:
#            spacing_open: 0
#            resizable: false
#            slidable: false
#            fxName: 'none'
#          west:
#            minSize: 310
#
#        container = $('#table')
#        previewContainer = $('#preview')
#        transformContainer = $('#transformEditor')
#        dashboardContainer = $("#wranglerDashboard")
#
#        wrangler.start
#          tableContainer: container
#          transformContainer: transformContainer
#          previewContainer: previewContainer
#          dashboardContainer: dashboardContainer
#
#        # TODO: find correct programmatic way to invoke header propagation
#        # assuming there always is a header in data, propagate it in Wrangler
#        $('#table .odd .rowHeader').first().mouseup().mousedown()
#        d3.select('div.menu_option.Promote')[0][0].__onmousedown()
#        $('div.suggestion.selected').click()
#]
