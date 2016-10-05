'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class GetDataDataService extends BaseModuleDataService
  @inject '$q', 'app_analysis_getData_msgService'

  # requires renaming message service injection to @msgService
  initialize: () ->
    @msgManager = @app_analysis_getData_msgService
    @getDataRequest = @msgManager.getMsgList().outgoing[0]
    @getDataResponse = @msgManager.getMsgList().incoming[0]
    @saveDataMsg = @msgManager.getMsgList().outgoing[1]
