'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name socrat.Module
  @desc Base class for module prototyping
  @deps Requires injection of BaseModuleMessageService
###

module.exports = class BaseModuleInitService extends BaseService

  initialize: ->
    @msgService = null unless @msgService?
    @sb = null
    @msgList =
      outgoing: []
      incoming: []
      scope: []

  init: (sb) ->
    console.log 'module init invoked'
    if @msgService?
      @msgService.setSb @sb unless !@sb?
      @msgList = @msgService.getMsgList()
    else
      console.log 'module cannot init: message service is not injected'

  destroy: () ->

  msgList: @msgList
