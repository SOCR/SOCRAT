'use strict'
###
  @dependencies: None
  @author: Selvam Palanimalai
###
charts = (angular.module 'app_analysis_charts', [])

###
  @description: Constructor for this module.
  @type: factory
###
charts.factory('app_analysis_charts_constructor', [
  'app_analysis_charts_manager'
  (manager)->
    (sb)->
      msgList = manager.getMsgList()
      manager.setSb sb unless !sb?

      init: (opt) ->
        console.log 'charts init called'


      destroy: () ->

      msgList: msgList
])

###
  @description: Manager for all communication b/w modules.
    Only this service inside this module, has access to sandbox.
  @type: service
###
charts.factory( 'app_analysis_charts_manager', [
  ()->
    _sb = null

    _msgList =
      outgoing: ['get table']
      incoming: ['take table']
      scope: ['charts']

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



.controller('VarCtrl', [
    'app_analysis_charts_manager'
    '$scope'
    (ctrlMngr, $scope) ->
      sb = ctrlMngr.getSb()

      token = sb.subscribe
      msg:'take table'
      msgScope:'charts'
      listener: (msg, data) ->
        $scope.data = data
        console.log data

      sb.publish
        msg:'get table'
        msgScope:['charts']
        callback: -> sb.unsubscribe token
])

