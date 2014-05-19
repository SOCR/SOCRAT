'use strict'

eventMngr = angular.module('app.eventMngr', [])

.service("eventMngr", () ->
  ()->
    sb = null
    msgList = null

    incomeCallbacks = {}

    _setSb: (_sb) ->
      return false if _sb is undefined
      sb = _sb

    _eventManager = (msg, data) ->
      try
      #_data = msgList.income[msg].method.apply null,data
        _data = incomeCallbacks[msg] data
        #last item in data is a promise.
        data[data.length - 1].resolve _data if _data isnt false
      catch e
        console.log e.message
        alert 'error in database'

      if sb?
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

    _listenToIncomeEvents: () ->
      for msg of msgList.income
        console.log 'subscribed for ' + msg
        sb.subscribe
          msg: msg
          listener: eventManager
          msgScope: msgList.scope
          context: console

    _setLocalListeners: (localMsgListeners) ->
      for event in localMsgListeners
        if event.msg in msgList.income
          incomeCallbacks[event.msg] = event.cb

    setSb: _setSb
    getMsgList: _getMsgList
    setMsgList: _setMsgList
    setLocalListeners: _setLocalListeners
    listenToIncomeEvents: _listenToIncomeEvents
)