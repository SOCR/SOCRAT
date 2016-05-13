'use strict'

#
# Base class for module data retrieving service
#

window.socrat or= {}

class socrat.DataService

  getData: (outMsg, inMsg) ->
    deferred = $q.defer()
    token = msgManager.subscribe inMsg, (msg, data) -> deferred.resolve data
    msgManager.publish outMsg, -> msgManager.unsubscribe token
    deferred.promise

  getDataTypes: ->
    msgManager.getSupportedDataTypes()
