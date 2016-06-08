'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name ModuleDataService
  @desc Base class for module data retrieval service
  @deps Requires injection of ModuleMessageService
###

module.exports = class ModuleDataService extends BaseService

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
