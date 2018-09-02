'use strict'

ModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class MyModuleInitService extends ModuleInitService

  @inject 'myModule_msgService'

  initialize: ->
    @msgService = @myModule_msgService
    @setMsgList()
