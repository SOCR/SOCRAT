'use strict'

#app.core module contains services like error management , pub/sub

mediator = angular.module('app.mediator', [])

#.service("sayHello", ["name", (name) ->
#  console.log("sayHello service is instantiated")
#  log: () ->
#    console.log "Hello" + name
#    null
#])

.service("pubSub", () ->
  _channelList = {}
  _lastUID = 14

  #publish() - registers channel if not present already,
  # then executes all the callbacks.
  _publish = (channel,data,cb) ->

    if cb is "undefined"
      cb = ->
    unless typeof channel is "string"
      return false

    if typeof data is "function"
      cb = data
      data = undefined

    if _channelList.hasOwnProperty(channel)
      subscribers=_channelList[channel]
      i = 0
      j = subscribers.length
      while i < j
        try
          #util.runSeries implementation goes here
          subscribers[i].func channel, data
        catch e
          throw e
        i++
    else
      _channelList[channel]=[]
  #  console.log(subscribers)

  #subscribe() - register a callback for an channel
  _subscribe = (channel,cb) ->
    if channel instanceof Array
      _results=[]
      i=0
      j=channel.length
      while i<j
        id = channel[i]
        _results.push _subscribe id, cb
        i++
      return _results
    else if channel instanceof Object
      _results=[]
      for k of channel
        v = channel[k]
        _results.push _subscribe k, v
      #console.log _channelList
      return _results
    else
      unless typeof cb == "function"
        return false
      unless typeof channel == "string"
        return false
    unless _channelList.hasOwnProperty(channel)
      _channelList[channel]=[]

    #pushing the cb function into the list
    _channelList[channel].push
      token:++_lastUID
      func:cb
    console.log("successfully subscribed")
    console.log(_channelList)
    _lastUID

  #_unsubscribe()
  _unsubscribe=(token)->
    for m of _channelList
      if _channelList.hasOwnProperty(m)
        i=0
        j=_channelList[m].length
        while i<j
          if _channelList[m][i].token is token
            _channelList[m].splice i, 1
            console.log("successfully unsubscribed")
            return token
          i++

  publish:_publish
  subscribe:_subscribe
  unsubscribe:_unsubscribe
)
