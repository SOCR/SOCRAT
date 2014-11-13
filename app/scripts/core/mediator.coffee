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
          _scopes.push _scope if _scope in _msgScopeList

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

  # _subscribe - registers a listener function for a msg
  _subscribe = (obj) ->

    if obj.msg? then msg = obj.msg else return false

    cb = if obj.listener? then obj.listener else ->

    # not sure about this
    context = if obj.context? then obj.context else @

    if obj.msgScope?
      msgScope = obj.msgScope

      if msgScope instanceof Array
        # adding the scope to the msgScope list if not present already
        for _scope in msgScope
          _msgScopeList.push _scope if _scope not in _msgScopeList

      else
        return false
    else
      return false

    if msg instanceof Array
      _results = []

      for m in msg
        _results.push _subscribe
          msg: m
          listener: cb
          context: context
          msgScope: msgScope
      return @

    else if msg instanceof Object
      _results = []

      for k, v of msg
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

    for _scope in msgScope

      _msgList[_scope] = {} if not _msgList[_scope]?
      _msgList[_scope][msg] = [] unless _msgList[_scope].hasOwnProperty msg

      # pushing the cb function into the list
      _msgList[_scope][msg].push
        token: ++_lastUID
        func: cb
        context: context

      console.log '%cMEDIATOR: successfully subscribed: ' + msg, 'color:blue'

    return @

  # _unsubscribe
  _unsubscribe = (token) ->

    for own i, msg of _msgList
      for m in msg
        if m.token is token
          msg.splice m, 1
          console.log '%cMEDIATOR: successfully unsubscribed: ' + i, 'color:blue'
          return token
    return @

  publish: _publish
  subscribe: _subscribe
  unsubscribe: _unsubscribe
)
