'use strict'

#
# Base class for module prototyping
#

window.socrat or= {}

class socrat.Module

  init: (sb) ->

    msgService.setSb sb unless !sb?
    msgList = msgService.getMsgList()

    ############

    init: (opt) ->
      console.log 'clustering init invoked'

    destroy: () ->

    msgList: msgList
