'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class GetDataInitService extends BaseModuleInitService
  @inject 'app_analysis_getData_msgService'

  initialize: ->
    @msgService = @app_analysis_getData_msgService
