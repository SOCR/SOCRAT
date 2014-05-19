'use strict'

#app.core module contains services like error management , pub/sub

mediator = angular.module('app.eventMngr', [])

# publish/subscribe angular service
.service("eventMngr", () ->
  ()->
    msgList = null

    incomeCallbacks = {}

    _eventManager = (msg, data) ->
      try
      #_data = msgList.income[msg].method.apply null,data
        _data = incomeCallbacks[msg] data
        #last item in data is a promise.
        data[data.length - 1].resolve _data if _data isnt false
      catch e
        console.log e.message
        alert 'error in database'

      sb.publish
        msg: msgList.income[msg].outcome
        data: _data
        msgScope: msgList.scope

#   Getter and setter for mgsList
    _getMsgList: () ->
      msgList

    _setMsgList: (_msgList) ->
      return false if _msgList is undefined
      sb = _msgList

    listenToIncomeEvents: () ->
      for msg of msgList.income
        console.log 'subscribed for ' + msg
        sb.subscribe
          msg: msg
          listener: eventManager
          msgScope: msgList.scope
          context: console

    setLocalListeners: (msg, cb) ->
      if msg in msgList.income
        incomeCallbacks[msg] = cb

    getMsgList:_getMsgList
    setMsgList:_setMsgList
    unsubscribe:_unsubscribe
  )
