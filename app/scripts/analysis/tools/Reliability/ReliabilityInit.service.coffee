'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class ReliabilityInitService extends BaseModuleInitService
  @inject 'app_analysis_reliability_msgService'

  initialize: ->
    @msgService = @app_analysis_reliability_msgService
    @setMsgList()
