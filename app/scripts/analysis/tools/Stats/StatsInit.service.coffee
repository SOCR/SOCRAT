'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class StatsInitService extends BaseModuleInitService
  @inject 'app_analysis_stats_msgService'

  initialize: ->
    @msgService = @app_analysis_stats_msgService
    @setMsgList()
