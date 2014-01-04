'use strict'
###
  depends on the app.mediator for publishing messages
###
errorMngr = angular.module 'app.errorMngr', ['app.mediator']

###
  overriding the default $exceptionHandler for custom exception handling.
###
###
  What is the structure of the err object?
  err={
    msg: "I am a error",
    type: "error",
    severity,
    display: {true,false}
  }
###
errorMngr.factory '$exceptionHandler', [
  '$log'
  'pubSub'

  ($log,pubSub) ->
    ###
      debugMode = 1 - switched ON
    ###
    _debugMode = 1
    ###
      @function _setDebugMode
      @param val
    ###
    _setDebugMode = (val) ->
      if val is 1 || val is 0
        _debugMode = val
      else
        return false
    ###
      @function _handle
      @param err - error object
    ###
    _handle = (err) ->
      # err has to be an object
      return false unless typeof err is "object"

      #setting debug mode
      if err.debug?
        _setDebugMode err.debug
        return true

      # message is required.
      unless err.message == ''
        # writing messages to console - debug mode
        if _debugMode is 1
          switch err.type
            when 'error'
              $log.error err.msg
            when 'log'
              $log.log err.msg
            when 'info'
              $log.info err.msg
            when 'warn'
              $log.warn err.msg
            else
              $log.log err.msg

        #if display is defined
        if err.display?
          if err.display is true
            # tell the view controller to show the error message
            console.log "DISPLAY"
            pubSub.publish
              message:"Display error to frontend"
              messageScope:["error"]
              data:err.message
      else
        return false

    (exception)->
      _handle(exception)

]
