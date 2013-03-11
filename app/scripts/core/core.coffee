'use strict'

#app.core module contains services like error management , pub/sub

core = angular.module('app.core', [
   'app.services'
])

#.service("sayHello", ["name", (name) ->
#  console.log("sayHello service is instantiated")
#  log: () ->
#    console.log "Hello" + name
#    null
#])

.service("pubSub", ()->
  _channelList={}
  _lastUID=14

  #publish() - registers channel if not present already,
  # then executes all the callbacks.
  _publish=(channel,data)->
    if _channelList.hasOwnProperty(channel)
      subscribers=_channelList[channel]
      i = 0
      j = subscribers.length
      while i < j
        try
          subscribers[i].func channel, data
        catch e
          throw e
        i++
    else
      _channelList[channel]=[]
    console.log(subscribers)

  #subscribe() - register a callback for an channel
  _subscribe=(channel,cb)->
    unless _channelList.hasOwnProperty(channel)
      _channelList[channel]=[]
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
