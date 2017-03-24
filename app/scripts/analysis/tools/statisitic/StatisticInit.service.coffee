'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class StatisticInitService extends BaseModuleInitService
  @inject 'app_analysis_statistic_msgService'

  initialize: ->
    @msgService = @app_analysis_statistic_msgService
    @setMsgList()
