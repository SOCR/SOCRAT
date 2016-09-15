'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class DatalibInitService extends BaseModuleInitService
  @inject 'app_analysis_datalib_msgService'

  initialize: ->
    @msgService = @app_analysis_datalib_msgService
    @setMsgList()
