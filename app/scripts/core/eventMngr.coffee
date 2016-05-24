'use strict'

require 'scripts/core/mediator.coffee'

eventMngr = angular.module('app_eventMngr', ['app_mediator'])

.service('eventMngr', [
  'pubSub'
  (pubSub) ->
    incomeCallbacks = {}

    # supported data types
    DATA_TYPES =
      'FLAT': 'FLAT'
      'NESTED': 'NESTED'

    _getSupportedDataTypes = () ->
      DATA_TYPES

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
    getSupportedDataTypes: _getSupportedDataTypes
    publish: pubSub.publish
    subscribe: pubSub.subscribe
    unsubscribe: pubSub.unsubscribe
])
