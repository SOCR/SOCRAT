'use strict'

eventMngr = angular.module('app_eventMngr', ['app_mediator', 'app_utils'])

.service("eventMngr", [
  'pubSub'
  'utils'
  (mediator, utils) ->
    incomeCallbacks = {}

    _setLocalListeners = (localMsgListeners) ->
      for event in localMsgListeners
        if event.inMsg in msgList.incoming
          if event.outMsg? and event.outMsg in msgList.outgoing
            incomeCallbacks[event.msg] = event.cb

    _eventManager = (msg, data) ->
      try
      #_data = msgList.income[msg].method.apply null,data
        _data = incomeCallbacks[msg] data
        #last item in data is a promise.
        data[data.length - 1].resolve _data if _data isnt false
      catch e
        console.log e.message
        alert 'error in database'

      mediator.publish
        msg: msgList.incoming[msg].outgoing
        data: _data
        msgScope: msgList.scope

#  #   Getter and setter for mgsList
#      _getMsgList: () ->
#        msgList
#
#      _setMsgList: (_msgList) ->
#        return false if _msgList is undefined
#        sb = _msgList

#    serialized subscription for arbitrary list of events
    _subscribeForEvents = (events, listnrList...) ->
      console.log 'subscribing for'
      console.log events
      console.log listnrList
      # if listener parameter is missing, set up default callback
      listnrList ?= _eventManager

      for i, msg of events.msgList
        console.log msg
        mediator.subscribe
          msg: msg
        # checking if array of listeners was passes as a parameter
          listener: if utils.typeIsArray listnrList then listnrList[i] else listnrList
          msgScope: events.scope
          context: events.context

    setLocalListeners: _setLocalListeners
    subscribeForEvents: _subscribeForEvents
    publish: mediator.publish
    subscribe: mediator.subscribe
])