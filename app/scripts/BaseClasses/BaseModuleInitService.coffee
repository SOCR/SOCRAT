'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name socrat.Module
  @desc Base class for module prototyping
  @deps Requires injection of BaseModuleMessageService
###

module.exports = class BaseModuleInitService extends BaseService

  initialize: ->
    @sb = null

  init: (sb) ->
    console.log 'module init invoked'
    if @msgService?
      @msgService.setSb @sb unless !@sb?
    else
      console.log 'module cannot init: message service is not injected'

  destroy: ->

  setMsgList: ->
    @msgList = @msgService.getMsgList() unless !@msgService?

  getMsgList: ->
    if @msgList? then @msgList else false
