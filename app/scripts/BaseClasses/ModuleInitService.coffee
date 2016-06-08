'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name socrat.Module
  @desc Base class for module prototyping
  @deps Requires injection of ModuleMessageService
###

module.exports = class ModuleInitService extends BaseService

  initialize: ->
    @sb = null
    @msgList =
      outgoing: []
      incoming: []
      scope: []

  init: (sb) ->
    console.log 'module init invoked'
    @msgService.setSb @sb unless !@sb?
    @msgList = @msgService.getMsgList()

  destroy: () ->

  msgList: @msgList
