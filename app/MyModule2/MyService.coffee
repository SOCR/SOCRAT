'use strict'

ModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class MyModuleMyService extends ModuleInitService
  @inject 'myModule_msgService'

  initialize: ->
    @myModule_msgService.subscribe 'count.distinct_res', (msg, data) => @message = data
    @msgManager.publish 'count.distinct', -> @msgManager.unsubscribe token, [1,1,2,3,4,5]

  @getMainMessage: -> @message
