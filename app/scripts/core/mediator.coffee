'use strict'

# Module app.core contains services like error management, pub/sub

mediator = angular.module('app_mediator', [])

# publish/subscribe angular service
.service('pubSub', ->
  _msgList = []
  _msgScopeList = []
  _scopes = []
  _lastUID = 14

  # _publish() - registers msg if not present already,
  #  then executes all the callbacks
  # @param {object}
  _publish = (obj) ->

    return false unless typeof obj.msg is 'string'

    cb = if obj.callback? then obj.callback else ->

    _flag = 1
    msg = obj.msg

    for _msgScope in _msgScopeList
      if _msgList[_msgScope].hasOwnProperty msg
        _flag = 0
        break

    if _flag is 1
      # execute the callback and return false
      console.log '%cMEDIATOR: message not present in the list ' + msg, 'color: blue'
      cb()
      return false

    data = if obj.data? then obj.data else undefined

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
        _scopes = []

        for _scope, i in msgScope
          if _scope is 'all'
            _scopes = _msgScopeList
            break
          if _msgScopeList.indexOf _scope isnt -1
            _scopes.push _scope

        for i, scope of _scopes
          if _msgList[scope].hasOwnProperty msg
            subscribers = _msgList[scope][msg]
            for subscriber in subscribers
              try
                #
                # util.runSeries implementation goes here
                #
                subscriber.func.apply subscriber.context, [msg, data]
              catch e
                throw e
          else
            console.log '%cMEDIATOR: no cb\'s registered with this message' + msg, 'color: blue'
            _msgList[scope][msg] = []

      else
        console.log '%cMEDIATOR: msgScope is not an Array instance' + msgScope, 'color: blue'
        throw new Error 'msgScope is not an Array instance'
#          message:'msgScope is not an Array instance'
#          type:'error'
    else
      throw new Error 'msgScope is not defined'
#        message:'msgScope is not defined'
#        type:'error'

    cb()
    console.log '%cMEDIATOR: successfully published ' + obj.msg, 'color: blue'
    return @

  # _subscribe() - registers a listener function for a msg
  _subscribe = (obj) ->

    if obj.msg?
      msg = obj.msg
    else
      return false

    cb = if obj.listener? then obj.listener else ->

    # not sure about this
    context = if obj.context? then obj.context else @

    if obj.msgScope?
      msgScope = obj.msgScope
      i = 0
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
      _results = []
      i = 0
      j = msg.length

      while i < j
        id = msg[i]
        _results.push _subscribe
          msg: id
          listener: cb
          context: context
          msgScope: msgScope
        i++
      return @

    else if msg instanceof Object
      _results = []
      for k of msg
        v = msg[k]
        _results.push _subscribe
          msg: k
          listener: v
          context: context
          msgScope: msgScope
      return _results

    else
      unless typeof cb == "function"
        return false
      unless typeof msg == "string"
        return false

    j = 0
    while j < msgScope.length

      if not _msgList[msgScope[j]]?
        _msgList[msgScope[j]] = {}

      unless _msgList[msgScope[j]].hasOwnProperty msg
        _msgList[msgScope[j]][msg] = []

      # pushing the cb function into the list
      _msgList[msgScope[j]][msg].push
        token: ++_lastUID
        func: cb
        context: context
      console.log '%cMEDIATOR: successfully subscribed: ' + msg, 'color:blue'
      j++

    return @

  # _unsubscribe
  _unsubscribe = (token) ->
    for m of _msgList
      if _msgList.hasOwnProperty m
        i = 0
        j = _msgList[m].length
        while i < j
          if _msgList[m][i].token is token
            _msgList[m].splice i, 1
            console.log '%cMEDIATOR: successfully unsubscribed: ' + m, 'color:blue'
            return token
          i++
    return @

  publish: _publish
  subscribe: _subscribe
  unsubscribe: _unsubscribe
)
