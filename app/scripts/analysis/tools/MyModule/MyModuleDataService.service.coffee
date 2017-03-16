'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'
module.exports = class MyModuleDataService extends BaseModuleDataService

  @inject '$q', 'socrat_analysis_mymodule_msgService'

  initialize: () ->
    @msgManager = @socrat_analysis_mymodule_msgService
    # indication of default messages for requesting and receiving data from SOCRAT
    @getDataRequest = @msgManager.getMsgList().outgoing[0]
    @getDataResponse = @msgManager.getMsgList().incoming[0]

  inferDataTypes: (data, cb) ->
    @post(@msgManager.getMsgList().outgoing[1], @msgManager.getMsgList().incoming[1], data).then (resp) =>
      cb resp
