'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class PowerCalcInitService extends BaseModuleInitService
  @inject 'app_analysis_powerCalc_msgService'

  initialize: ->
    @msgService = @app_analysis_powerCalc_msgService
    @setMsgList()
