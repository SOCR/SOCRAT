'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class app_analysis_mymodule_initService extends BaseModuleInitService
  @inject 'app_analysis_mymodule_msgService'

  initialize: ->
    @msgService = @app_analysis_mymodule_msgService
    @setMsgList()
