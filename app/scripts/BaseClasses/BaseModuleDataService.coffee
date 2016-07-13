'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name BaseModuleDataService
  @desc Base class for module data retrieval service
  @deps Requires injection of BaseModuleMessageService
###

module.exports = class BaseModuleDataService extends BaseService

  # injected:
  # @msgManager

  initialize: () ->

  getData: (outMsg, inMsg) ->
    deferred = @$q.defer()
    token = @msgManager.subscribe inMsg, (msg, data) -> deferred.resolve data
    @msgManager.publish outMsg, -> @msgManager.unsubscribe token
    deferred.promise

  getDataTypes: ->
    @msgManager.getSupportedDataTypes()
