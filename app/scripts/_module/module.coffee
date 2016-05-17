'use strict'

#
# Base class for module prototyping
#

window.socrat or= {}

class socrat.Module
  constructor: (@msgService) ->
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
