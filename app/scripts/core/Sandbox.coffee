'use strict'

#
# app_sandbox module for wrapping modules
#
class Sandbox
  constructor: (_core, _instanceId, _options = {}) ->

    @core = _core
    @instanceId = _instanceId
    @options = _options

    # TODO: throwing error through $exceptionHandler
    throw new TypeError "core was not defined" unless @core?
    throw new TypeError "no id was specified" unless @instanceId?
    if typeof @instanceId isnt "string"
      throw new TypeError "id is not a string"

angular.module 'app_sandbox', []
  .service 'Sandbox', -> Sandbox

