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
      outgoing: ['data wrangled', 'handsontable updated']
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

.factory('app_analysis_wrangleData_dataAdaptor', [
  () ->
    # accepts DataWrangler format as input and returns dataFrame
    _toDataFrame = () ->

    _toDataWranglerFormat = () ->

    toDataFrame: _toDataFrame
    toDataWranglerFormat: _toDataWranglerFormat
])

.controller('wrangleDataSidebarCtrl', [
    'app_analysis_wrangleData_manager'
    (wrangleDataEventMngr) ->
      console.log 'wrangleDataSidebarCtrl executed'
  ])

.controller('wrangleDataMainCtrl', [
    'app_analysis_wrangleData_manager'
    (wrangleDataEventMngr) ->

      w = dw.wrangle()

      console.log 'wrangleDataMainCtrl executed'
  ])

.directive 'datawrangler', [
  'app_analysis_wrangleData_dataAdaptor'
  '$exceptionHandler'
  (dataAdaptor, $exceptionHandler) ->

    restrict: 'E'
    transclude: true
    templateUrl: '../partials/analysis/wrangleData/wrangler.html'

    #the controller for the directive
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

      startWrangler = (dt) ->

        dw.wrangler
          tableContainer: container
          table: dt
          transformContainer: $('#transformEditor')
          previewContainer: previewContainer
          dashboardContainer: $("#wranglerDashboard")
          initial_transforms: initial_transforms


    replace: true #replace the directive element with the output of the template.

    #the link method does the work of setting the directive
    # up, things like bindings, jquery calls, etc are done in here
    # It is run before the controller
    link: (scope, elem, attr) ->

      # useful to identify which handsontable instance to update
      scope.purpose = attr.purpose
]
