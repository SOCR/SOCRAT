'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ProjectorDataService extends BaseModuleDataService
  @inject '$q', 'app_analysis_projector_msgService'

  # requires renaming message service injection to @msgService
  initialize: () ->
    @msgManager = @app_analysis_projector_msgService
    @getDataRequest = @msgManager.getMsgList().outgoing[0]
    @getDataResponse = @msgManager.getMsgList().incoming[0]

