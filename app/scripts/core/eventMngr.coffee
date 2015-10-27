'use strict'

eventMngr = angular.module('app_eventMngr', ['app_mediator', 'app_utils'])

.service('eventMngr', [
  'pubSub'
  'utils'
  (pubSub, utils) ->
    incomeCallbacks = {}

#    _defaultEventManager = (msg, data) ->
#      try
#      #_data = msgList.income[msg].method.apply null,data
#        _data = incomeCallbacks[msg] data
#        #last item in data is a promise.
#        data[data.length - 1].resolve _data if _data isnt false
#      catch e
#        console.log e.message
#
#      pubSub.publish
#        msg: msg
#        data: _data

    # Serialized subscription for a list of events
    _subscribeForEvents = (events, listener) ->

      for msg in events.msgList
        console.log msg
        pubSub.subscribe
          msg: msg
          listener: listener
          msgScope: events.scope
          context: events.context

    subscribeForEvents: _subscribeForEvents
    publish: pubSub.publish
    subscribe: pubSub.subscribe
    unsubscribe: pubSub.unsubscribe
])