'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ModelerDataService extends BaseModuleDataService
  @inject '$q', 'socrat_analysis_mymodule_msgService'

  # requires renaming message service injection to @msgService
  initialize: () ->
    @msgManager = @socrat_analysis_mymodule_msgService
    @getDataRequest = @msgManager.getMsgList().outgoing[0]
    @getDataResponse = @msgManager.getMsgList().incoming[0]

  inferDataTypes: (data, cb) ->
    @post(@msgManager.getMsgList().outgoing[1], @msgManager.getMsgList().incoming[1], data).then (resp) =>
      cb resp
