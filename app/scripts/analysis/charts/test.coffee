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
        console.log 'db init called'
        manager.listenToIncomeEvents()

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
    sb = null

    msgList =
      outgoing: ['get table']
      incoming: ['take table']
      scope: ['charts']

    eventManager = (msg, data) ->
      try
        _data = msgList.income[msg].method.apply null,data
        #last item in data is a promise.
        data[data.length - 1].resolve _data if _data isnt false
      catch e
        console.log e.message
        alert 'error in database'

      sb.publish
        msg: msgList.income[msg].outcome
        data: _data
        msgScope: msgList.scope

    setSb: (_sb) ->
      return false if _sb is undefined
      sb = _sb

    getMsgList: () ->
      msgList

    listenToIncomeEvents: () ->
#app_analysis_charts_compute()
      for msg of msgList.income
        console.log 'subscribed for ' + msg
        sb.subscribe
          msg: msg
          listener: eventManager
          msgScope: msgList.scope
          context: console
])




