'use strict'

#
# Base class for module prototyping
#
root = exports ? this
class root.Module
  constructor: () ->

  init: (sb) ->

    msgList = {}
    msgService.setSb sb unless !sb?
    msgList = msgService.getMsgList()

    ############

    init: (opt) ->
      console.log 'clustering init invoked'

    destroy: () ->

    msgList: msgList
