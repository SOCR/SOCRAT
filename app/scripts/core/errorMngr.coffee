'use strict'

####
#  overriding the default $exceptionHandler for custom exception handling.
####
####
#  What is the structure of the err object?
#  err={
#    msg: "I am a error",
#    type: "error",
#    severity,
#    display: {true,false}
#  }
####
module.exports = class ErrorMngr

  constructor: ($log,pubSub) ->
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
      alert "Error"
      console.log "ERROR MANAGER"
      console.log err
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
              $log.error err.message
            when 'log'
              $log.log err.message
            when 'info'
              $log.info err.message
            when 'warn'
              $log.warn err.message
            else
              $log.log err.message
              $log.log err.stack

        #if display is defined
        if err.display?
          if err.display is true
            # tell the view controller to show the error message
            pubSub.publish
              msg:"Display error to frontend"
              msgScope:["error"]
              data:err.message
      else
        return false

    (exception)->
      _handle(exception)


# inject dependencies
ErrorMngr.$inject = [
  '$log',
  'pubSub'
]

angular.module('app_errorMngr', ['app_mediator'])
  .service 'errorMngr', ErrorMngr

