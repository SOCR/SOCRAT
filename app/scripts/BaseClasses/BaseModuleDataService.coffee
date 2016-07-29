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

  getData: (outMsg=null, inMsg=null) ->
    deferred = @$q.defer()
    # by default use first messages
    if @getDataRequest? and not outMsg
      outMsg = @getDataRequest
    if @getDataResponse? and not inMsg
      inMsg = @getDataResponse
    if outMsg and inMsg

      token = @msgManager.subscribe inMsg, (msg, data) -> deferred.resolve data
      @msgManager.publish outMsg, -> @msgManager.unsubscribe token
    else
      deferred.reject()

    deferred.promise

  getDataTypes: ->
    @msgManager.getSupportedDataTypes()
