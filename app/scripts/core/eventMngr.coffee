'use strict'

require 'scripts/core/mediator.coffee'

###
# @name eventMngr
# @desc Class for managing module interactions
###
module.exports = class EventMngr

  constructor: (@pubSub) ->

  # supported data types
  @_DATA_TYPES:
    'FLAT': 'FLAT'
    'NESTED': 'NESTED'

  # serialized subscription for a list of events
  @_subscribeForEvents: (events, listener) ->

    for msg in events.msgList
      @pubSub.subscribe
        msg: msg
        listener: listener
        msgScope: events.scope
        context: events.context

  @_redirectMsg = (msg, data) ->
    matches = 0
    for o in _map when o.msgFrom is msg
      @pubSub.publish
        msg: o.msgTo
        data: data
        msgScope: o.scopeTo
      console.log '%cEVENT MANAGER: redirect mgs ' + o.msgTo + ' to ' + o.scopeTo, 'color:blue'
      matches += 1
    if matches == 0
      console.log '%ccEVENT MANAGER: no mapping in API for message: ' + o.msgTo, 'color:blue'
      return false
    else
      return true

  getInterface: ->
    subscribeForEvents: => @constructor._subscribeForEvents
    redirectMsg: => @constructor._redirectMsg
    getSupportedDataTypes: => @constructor._DATA_TYPES
    publish: (obj) => @pubSub.publish obj
    subscribe: (obj) => @pubSub.subscribe obj
    unsubscribe: (tokens) => @pubSub.unsubscribe tokens

# inject dependencies
EventMngr.$inject = [
  'pubSub'
]

angular.module('app_eventMngr', ['app_mediator'])
  .service 'eventMngr', EventMngr
