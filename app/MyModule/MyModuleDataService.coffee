'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class MyModuleDataService extends BaseModuleDataService
  @inject '$q', 'myModule_msgService'

  # requires renaming message service injection to @msgService
  initialize: () ->
    @msgManager = @myModule_msgService
    @getDataRequest = @msgManager.getMsgList().outgoing[0]
    @getDataResponse = @msgManager.getMsgList().incoming[0]

  inferDataTypes: (data, cb) ->
    @post(@msgManager.getMsgList().outgoing[1], @msgManager.getMsgList().incoming[1], data).then (resp) =>
      cb resp

  countUnique: (data, cb) ->
    @post(@msgManager.getMsgList().outgoing[2], @msgManager.getMsgList().incoming[2], data).then (resp) =>
      cb resp
