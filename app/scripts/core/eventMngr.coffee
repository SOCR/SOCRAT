'use strict'

eventMngr = angular.module('app.eventMngr', ['app.mediator'])

.service("eventMngr", [
  'pubSub'
  (mediator) ->
    ()->

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

      _subscribeForEvents: (msgList, listener=eventManager) ->
        for msg of msgList
          mediator.subscribe
            msg: msg
            listener: listener
            msgScope: msgList.scope
            context: console

      _setLocalListeners: (localMsgListeners) ->
        for event in localMsgListeners
          if event.inMsg in msgList.incoming
            if event.outMsg? and event.outMsg in msgList.outgoing
              incomeCallbacks[event.msg] = event.cb

      setSb: _setSb
      getMsgList: _getMsgList
      setMsgList: _setMsgList
      setLocalListeners: _setLocalListeners
      subscribeForEvents: _subscribeForEvents
])