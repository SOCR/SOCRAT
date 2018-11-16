'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class SVMInitService extends BaseModuleInitService
  @inject 'app_analysis_classification_msgService'

  initialize: ->
    @msgService = @app_analysis_classification_msgService
    @setMsgList()
