'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class DimReductionInitService extends BaseModuleInitService
  @inject 'app_analysis_dimReduction_msgService'

  initialize: ->
    @msgService = @app_analysis_dimReduction_msgService
    @setMsgList()
