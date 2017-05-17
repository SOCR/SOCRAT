'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class MyModuleInitService extends BaseModuleInitService
  @inject 'socrat_analysis_mymodule_msgService'

  initialize: ->
    @msgService = @socrat_analysis_mymodule_msgService
    @setMsgList()
