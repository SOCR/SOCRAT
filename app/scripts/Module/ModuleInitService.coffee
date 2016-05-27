'use strict'

###
# @name socrat.Module
# @desc Base class for module prototyping
###
module.exports = class ModuleInitService
  constructor: (@msgService) ->
    console.log 'MODULE INIT SERVICE'
    console.log @
    @sb = null
    @msgList =
      outgoing: []
      incoming: []
      scope: []

  init: (opt) ->
    console.log 'clustering init invoked'
    @msgService.setSb @sb unless !@sb?
    @msgList = @msgService.getMsgList()

  destroy: () ->

  msgList: @msgList
