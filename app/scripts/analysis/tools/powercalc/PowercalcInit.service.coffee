'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class PowercalcInitService extends BaseModuleInitService
  @inject 'app_analysis_powercalc_msgService'

  initialize: ->
    @msgService = @app_analysis_powercalc_msgService
    @setMsgList()
