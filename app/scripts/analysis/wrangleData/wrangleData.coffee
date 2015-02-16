'use strict'

wrangleData = angular.module('app_analysis_wrangleData', [])

.config([
    () ->
      console.log 'config block of wrangleData'
])

.factory('app_analysis_wrangleData_constructor', [
  'app_analysis_wrangleData_manager'
  (manager) ->
    (sb) ->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'wrangleData init invoked'

      destroy: () ->

      msgList: _msgList
])

.factory('app_analysis_wrangleData_manager', [
  () ->
    _sb = null

    _msgList =
      outgoing: ['data wrangled', 'handsontable updated', 'get data']
      incoming: ['wrangle data']
      scope: ['wrangleData']

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

.factory('app_analysis_wrangleData_dataRetriever', [
    'app_analysis_wrangleData_manager'
    'app_analysis_wrangleData_dataAdaptor'
    (manager, dataAdaptor) ->

      _data = null

      _sb = manager.getSb()

      _getData = (cb) ->

        token = _sb.subscribe
          msg: 'wrangle data'
          msgScope: ['wrangleData']
          listener: (msg, data) ->
            console.log data
            _data = dataAdaptor.toDvTable(data)
            cb(_data)

        _sb.publish
          msg: 'get data'
          msgScope: ['wrangleData']
          callback: -> _sb.unsubscribe token
          data:
#            tableName: $stateParams.projectId + ':' + $stateParams.forkId
            tableName: 'undefined:undefined'

      getData: _getData
  ])

.factory('app_analysis_wrangleData_dataAdaptor', [
  () ->

    _toDvTable = (dataFrame) ->

      table = []

      # transpose array to make it column oriented
      _data = ((row[i] for row in dataFrame.data) for i in [0...dataFrame.nCols])

      for i, col of _data
        table.push
          name: dataFrame.header[i]
          values: col
          type: 'symbolic'

      table

    _toDataFrame = (table) ->

      _nRows = table[0].length
      _nCols = table.length

      # transpose array to make it row oriented
      _data = ((col[i] for col in table) for i in [0..._nRows])

      _header = (col.name for col in table)
      _types = (col.type for col in table)

      dataFrame =
        data: _data
        header: _header
        types: _types
        nRows: _nRows
        nCols: _nCols

    toDvTable: _toDvTable
    toDataFrame: _toDataFrame
])

.controller('wrangleDataSidebarCtrl', [
    '$scope'
    'app_analysis_wrangleData_manager'
    ($scope, wrangleDataEventMngr) ->
      console.log 'wrangleDataSidebarCtrl executed'
      $scope.$parent.toggle()
  ])

.controller('wrangleDataMainCtrl', [
    'app_analysis_wrangleData_manager'
    (wrangleDataEventMngr) ->

      w = dw.wrangle()

      console.log 'wrangleDataMainCtrl executed'
  ])

.directive 'datawrangler', [
  'app_analysis_wrangleData_dataRetriever'
  '$exceptionHandler'
  (dataAdaptor, dataRetriever, $exceptionHandler) ->

    restrict: 'E'
    transclude: true
    templateUrl: '../partials/analysis/wrangleData/wrangler.html'

    # the controller for the directive
    controller: ($scope) ->

      myLayout = $('#dt_example').layout
        north:
          spacing_open: 0
          resizable: false
          slidable: false
          fxName: 'none'
        south:
          spacing_open: 0
          resizable: false
          slidable: false
          fxName: 'none'
        west:
          minSize: 310

      container = $('#table')
      previewContainer = $('#preview')

      initial_transforms = [];

      _startWrangler = (dt) ->

        dw.wrangler
          tableContainer: container
          table: dt
          transformContainer: $('#transformEditor')
          previewContainer: previewContainer
          dashboardContainer: $("#wranglerDashboard")
          initial_transforms: initial_transforms

#      data = dataRetriever.getData(_startWrangler)

      dt = dv.table crime
      initial_transforms = dw.raw_inference(crime).transforms
      _startWrangler dt

    replace: true # replace the directive element with the output of the template

    # The link method does the work of setting the directive
    #  up, things like bindings, jquery calls, etc are done in here
    #  It is run before the controller
    link: (scope, elem, attr) ->

      # useful to identify which handsontable instance to update
      scope.purpose = attr.purpose
]
