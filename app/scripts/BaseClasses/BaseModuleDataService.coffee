'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name BaseModuleDataService
  @desc Base class for module data retrieval service
  @deps Requires injection of BaseModuleMessageService
###

module.exports = class BaseModuleDataService extends BaseService

  initialize: () ->
    @getDataRequest = null
    @getDataResponse = null

  getData: (outMsg=null, inMsg=null, deferred=null) ->
    deferred = @$q.defer() unless deferred?
    # by default use first messages
    if @getDataRequest? and not outMsg
      outMsg = @getDataRequest
    if @getDataResponse? and not inMsg
      inMsg = @getDataResponse
    if outMsg and inMsg

      token = @msgManager.subscribe inMsg, (msg, data) -> deferred.resolve data
      @msgManager.publish outMsg, -> @msgManager.unsubscribe token, null, deferred
    else
      deferred.reject()

    deferred.promise

  saveData: (outMsg=null, cb=null, data, deferred=null) ->
    deferred = @$q.defer() unless deferred?
    # by default use second messages
    if @saveDataMsg? and not outMsg
      outMsg = @saveDataMsg
    if data and outMsg
      @msgManager.publish outMsg, ->
        @msgManager.unsubscribe token
        cb() if cb?
        deferred.resolve
      , data, deferred
    else
      deferred.reject()

    deferred.promise

  getDataTypes: ->
    @msgManager.getSupportedDataTypes()
