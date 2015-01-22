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

# ###
# wrangleDataSidebarCtrl is the ctrl that talks to the view.
# ###
.controller('wrangleDataSidebarCtrl', [
  'app_analysis_wrangleData_manager'
  (wrangleDataEventMngr) ->
    console.log 'wrangleDataSidebarCtrl executed'
])

.controller('wrangleDataMainCtrl', [
  'app_analysis_wrangleData_manager'
  (wrangleDataEventMngr) ->
    console.log 'wrangleDataMainCtrl executed'
])

# ###
# @name: app_analysis_wrangleData2dataFrame
# @type: factory
# @description: reformats data from input table format to the universal dataFrame object
# ###
.factory('app_analysis_wrangleData_dataAdaptor', [
  () ->

    # accepts DataWrangler format as input and returns dataFrame
    _toDataFrame = () ->

    _toDataWranglerFormat = () ->

    toDataFrame: _toDataFrame
    toDataWranglerFormat: _toDataWranglerFormat
])
