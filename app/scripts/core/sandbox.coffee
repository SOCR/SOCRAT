'use strict'

# app.sandbox module for wrapping modules

sandbox = angular.module('app.sandbox', [])

  .factory 'Sandbox', [$exceptionHandler, ->

    (_core, _instanceId, _options = {}) ->
      @core = _core
      @instanceId = _instanceId
      @options = _options

      # TODO: throwing error through $exceptionHandler
      throw new TypeError "core was not defined" unless @core?
      throw new TypeError "no id was specified"  unless instanceId?
      throw new TypeError "id is not a string"   unless typeof instanceId is "string"
  ]