'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class DataWranglerInitService extends BaseModuleInitService
  @inject 'app_analysis_dataWrangler_msgService'

  initialize: ->
    @msgService = @app_analysis_dataWrangler_msgService
    @setMsgList()
