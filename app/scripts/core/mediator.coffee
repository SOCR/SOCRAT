'use strict'

#app.core module contains services like error management , pub/sub

mediator = angular.module('app_mediator', [])

# publish/subscribe angular service
.service("pubSub", () ->
  _msgList = []
  _msgScopeList = []
  _scopes = []
  _lastUID = 14

  # _publish() - registers msg if not present already,
  # then executes all the callbacks.
  # @param {object}
  _publish = (obj) ->
    unless typeof obj.msg is "string"
      return false
    if obj.callback?
      cb = obj.callback
    else
      cb = ()->
    _flag = 1
    if obj.msg?
      msg = obj.msg
      i=0
      while i<_msgScopeList.length
        if _msgList[_msgScopeList[i]].hasOwnProperty(msg) is true
          _flag = 0
          break
        i++
    if(_flag is 1)
      # execute the callback and return false
      console.log "MEDIATOR: message not present in the list. returning false"
      cb()
      return false

    if obj.data?
      data = obj.data
    else
      data = undefined
    if obj.msgScope?
      msgScope = obj.msgScope
      if msgScope instanceof Array
        # search in the scopelist. if not there, move on
        # search in msglist, if not found move on to next el
        # if found, run all the listeners of that msg
        # move on to next el
        # adding the scope to the msgScope list if not present already
        # take each element of msgScope
        # if element is one, and = to "all" , search in all scopelists
        i=0
        _scopes =[]
        while i < msgScope.length
          if(msgScope[i] is "all")
            _scopes = _msgScopeList
            break
          if _msgScopeList.indexOf(msgScope[i]) isnt -1
            _scopes.push(msgScope[i])
          i++
        # Now we have the _scopes list, find messages and make calls
        i=0
        while i < Object.keys(_scopes).length
          if _msgList[_scopes[i]].hasOwnProperty(msg)
            subscribers=_msgList[_scopes[i]][msg]
            j = 0
            while j < subscribers.length
              try
              #
              # util.runSeries implementation goes here
              #
                subscribers[j].func.apply subscribers[j].context, [msg, data]
              catch e
                throw e
              j++
          else
            console.log "MEDIATOR: no cb's registered with this message"
            _msgList[_scopes[i]][msg]=[]
          i++
      else
        console.log 'MEDIATOR: msgScope is not an Array instance'
        throw new Error 'msgScope is not an Array instance'
#          message:'msgScope is not an Array instance'
#          type:'error'
    else
      throw new Error 'msgScope is not defined'
#        message:'msgScope is not defined'
#        type:'error'
    cb()
    console.log '%c MEDIATOR:successfully published'+obj.msg,'color: blue'
    return @

  # _subscribe() - registers a listener function for a msg
  _subscribe = (obj) ->
    if obj.msg?
      msg = obj.msg
    else
      return false

    if obj.listener?
      cb = obj.listener
    else
      cb = ->

    # not sure about this
    if obj.context?
      context = obj.context
    else
      context = this

    if obj.msgScope?
      msgScope = obj.msgScope
      i=0
      if msgScope instanceof Array
        # adding the scope to the msgScope list if not present already
        while i < msgScope.length
          if _msgScopeList.indexOf(msgScope[i]) is -1
            _msgScopeList.push msgScope[i]
          i++
      else
        return false
    else
      return false
    if msg instanceof Array
      _results=[]
      i=0
      j=msg.length
      while i<j
        id = msg[i]
        _results.push _subscribe
          msg:id
          listener:cb
          context:context
          msgScope:msgScope
        i++
      return @
    else if msg instanceof Object
      _results=[]
      for k of msg
        v = msg[k]
        _results.push _subscribe
          msg:k
          listener:v
          context:context
          msgScope:msgScope
      #console.log _msgList
      return _results
    else
      unless typeof cb == "function"
        return false
      unless typeof msg == "string"
        return false

    j=0
    while j < msgScope.length
      if not _msgList[msgScope[j]]?
        _msgList[msgScope[j]] = {}
      unless _msgList[msgScope[j]].hasOwnProperty(msg)
        _msgList[msgScope[j]][msg]=[]
      #pushing the cb function into the list
      _msgList[msgScope[j]][msg].push
        token:++_lastUID
        func:cb
        context:context
      console.log '%c MEDIATOR:successfully subscribed '+msg,'color: blue'
      j++

    return @

  #_unsubscribe()
  _unsubscribe=(token)->
    for m of _msgList
      if _msgList.hasOwnProperty(m)
        i=0
        j=_msgList[m].length
        while i<j
          if _msgList[m][i].token is token
            _msgList[m].splice i, 1
            console.log('MEDIATOR: successfully unsubscribed:' + m)
            console.log '%c MEDIATOR:successfully unsubscribed'+m,'color: blue'
            return token
          i++
    return @

  publish:_publish
  subscribe:_subscribe
  unsubscribe:_unsubscribe
)
