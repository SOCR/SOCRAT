'use strict'

qualRobEst = angular.module('app.qualRobEst', [
  #The frontend modules (app.getData,app.cleanData etc) should have
  # no dependency from the backend.
  #Try to keep it as loosely coupled as possible
])

.config([
  # ###
  # Config block is for module initialization work.
  # services, providers from ng module (such as $http, $resource)
  # can be injected here.
  # services, providers in this module CANNOT be injected
  # in the config block.
  # config block is run before their initialization.
  # ###
  () ->
    console.log "config block of qualRobEst"
])

####
#  Every module is supposed have a factory method
#  by its name. For example, "app.charts" module will
#  have "charts" factory method.
#
#  This method helps in module initialization.
#  init() and destroy() methods should be present in
#  returned object.
####
.factory('qualRobEst_constructor', [
  'qualRobEst_manager'
  (qualRobEstMngr) ->
    (sb) ->
      qualRobEstMngr.setSb sb unless !sb?

      init: (opt) ->
        console.log 'qualRobEst init invoked'
        # TODO: need to use this or just setLocalListener (which will subscribe automatically inside eventMngr)?
        # TODO: i.e. does module listen for incoming events if components didn't ask about it?
#        sb.subscribeForEvents(
#          qualRobEstMngr.msgList.incoming
#          qualRobEstMngr.eventManager
#        ) unless !sb?

        destroy: () ->

      msgList: qualRobEstMngr.msgList
])
####
# Every module will have a MODULE_NAMEEventMngr() service
# which provides messaging with core
####
.service('qualRobEst_manager', [
  () ->
    _sb = null

    _msgList =
      outgoing: ['numbers added']
      incoming: ['add numbers']
      scope: ['qualRobEst']

    setSb: (sb) ->
      return false if sb is undefined
      _sb = sb

    getMsgList: () ->
      _msgList

    sb: _sb
])
####
# Service for parameters estimation
####
.service('estimator', [
  'qualRobEst_manager'
  (qualRobEstMngr) ->
#    qualRobEstMngr.sb.setLocalListener 'add numbers', (data) ->
      qualRobEstMngr.sb.subscribe 'add numbers', (data) ->
      console.log '--- parameters estimation --> just return concatenation ---'
      sum = data.a + data.b
      qualRobEstMngr.sb.publish
        msg: 'numbers added'
        data: sum
        msgScope: qualRobEst
])
