'use strict'

errorMngr = angular.module 'app.errorMngr', []

###
  overriding the default $exceptionHandler for custom exception handling.
###
###
  What is the structure of the err object?
  err={
    msg: "I am a error",
    type: "error",
    severity
  }
###
errorMngr.factory '$exceptionHandler', ['$log', ($log) ->
  ###
    debugMode = 1 - switched ON
  ###
  _debugMode = 1
  ###
    @function _setDebugMode
    @param val
    @description
  ###
  _setDebugMode = (val) ->
    if val is 1 || val is 0
      _debugMode = val
    else
      return false

  _handle = (err) ->
    unless err.message == '' || err.priority == ''
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

      # switch case for priority
      switch err.priority
        when 0
          break
        when 1
          break
    else
      return false

  setDebugMode:_setDebugMode
  handle:_handle

]
