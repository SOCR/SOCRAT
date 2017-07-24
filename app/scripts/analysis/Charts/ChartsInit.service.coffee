'use strict'

ModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class ChartsInitService extends ModuleInitService
  
  @inject 'app_analysis_charts_msgService'

  initialize: ->
    @msgService = @app_analysis_charts_msgService
    @setMsgList()
