'use strict'

require 'scripts/core/mediator.coffee'

###
# @name EventMngr
# @desc Class for managing module interactions
###
module.exports = class EventMngr

  constructor: (@pubSub) ->

  # supported data types
  @_DATA_TYPES:
    'FLAT': 'FLAT'
    'NESTED': 'NESTED'

  # serialized subscription for a list of events
  subscribeForEvents: (events, listener) ->

    for msg in events.msgList
      @subscribe
        msg: msg
        listener: listener
        msgScope: events.scope
        context: events.context

  redirectMsg: (msg, data) ->
    matches = 0
    for o in _map when o.msgFrom is msg
      @publish
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
    subscribeForEvents: @subscribeForEvents
    redirectMsg: @redirectMsg
    getSupportedDataTypes: => @constructor._DATA_TYPES
    publish: @pubSub.publish
    subscribe: @pubSub.subscribe
    unsubscribe: @pubSub.unsubscribe

# inject dependencies
EventMngr.$inject = [
  'pubSub'
]

angular.module('app_eventMngr', ['app_mediator'])
  .service 'eventMngr', EventMngr
