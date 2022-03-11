'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class JiaruiLiuDataService extends BaseModuleDataService
  @inject '$q', 'socrat_analysis_JiaruiLiu_msgService'

  # requires renaming message service injection to @msgService
  initialize: () ->
    @msgManager = @socrat_analysis_JiaruiLiu_msgService
    @getDataRequest = @msgManager.getMsgList().outgoing[0]
    @getDataResponse = @msgManager.getMsgList().incoming[0]
    @saveDataMsg = @msgManager.getMsgList().outgoing[1]