# Create mock module and overriding services
angular.module('app_mocks', [])
  .factory 'Sandbox', ->
    (_core, _instanceId, _options = {}) ->
      @core = @
      @instanceId = _instanceId
      @options = {}

  .service 'pubSub', ->
    @events = []
    @publish = (event) =>
        console.log 'mock pubSub: published for '+event.msg
        #console.log event
        #console.log @events[0]?.listener
        #console.log event.data
        result = (item.listener(item.msg,event.data) for item in @events when item.msg is event.msg)
    @subscribe = (event) =>
      @events.push event
      console.log 'mock pubSub: subscribed'
      console.log @events
    @unsubscribe = ->
    publish: @publish
    subscribe: @subscribe
    unsubscribe: @unsubscribe

  .service('eventMngr', [
    'pubSub'
    'utils'
    (pubSub, utils) ->
      @incomeCallbacks = {}
      @eventManager = (msg, data) ->
        try
          _data = @incomeCallbacks[msg] data
        catch e
          console.log e.message
      @subscribeForEvents = (events, listnrList...) ->
        listnrList ?= @eventManager

        for i, msg of events.msgList
          console.log msg
          console.log pubSub.subscribe
          pubSub.subscribe
            msg: msg
          # checking if array of listeners was passes as a parameter
            listener: if utils.typeIsArray listnrList then listnrList[i] else listnrList
            msgScope: events.scope
      subscribeForEvents: @subscribeForEvents
      publish: pubSub.publish
      subscribe: pubSub.subscribe
  ])
