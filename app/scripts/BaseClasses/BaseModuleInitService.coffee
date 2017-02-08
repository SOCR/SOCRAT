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
    if sb?
      @sb = sb
      true
    else
      console.log 'ERROR: module cannot init, sb is not available'
      false
#    if @msgService?
#      @msgService.setSb sb unless !sb?
#      true
#    else
#      console.log 'module cannot init: message service is not injected'
#      false

  destroy: ->

  setMsgList: (msgList) ->
    if msgList?
      @msgList = msgList
      true
    else false
#    @msgList = @msgService.getMsgList() unless !@msgService?

  getMsgList: ->
    if @msgList? then @msgList else false
