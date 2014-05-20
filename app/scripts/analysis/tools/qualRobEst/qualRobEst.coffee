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
.factory('qualRobEst', [
  'qualRobEstEventMngr'
  'estimator'
  (qualRobEstEventMngr) ->
    (sb) ->

      msgList = qualRobEstEventMngr.getMsgList()
      qualRobEstEventMngr.setSb sb unless !sb?

      init: (opt) ->
        console.log 'qualRobEst init invoked'
        qualRobEstEventMngr.listenToIncomeEvents()

      destroy: () ->

      msgList: msgList
])
####
# Every module will have a MODULE_NAMEEventMngr() service
# which provides messaging with core
####
.service('qualRobEstEventMngr', [
  () ->
    sb = null

    msgList =
      outgoing: ['234']
      incoming: ['123']
      scope: ['qualRobEst']

    incomeCallbacks = {}

    eventManager = (msg, data) ->
      console.log incomeCallbacks
      sb.publish
        msg: msgList.outcome[0]
        data: incomeCallbacks[msg] data
        msgScope: msgList.scope

    setSb: (_sb) ->
      return false if _sb is undefined
      sb = _sb

    getMsgList: () ->
      msgList

    listenToIncomeEvents: () ->
      console.log 'subscribed for ' + msgList.incoming[0]
      sb.subscribe
        msg: msgList.incoming[0]
        listener: eventManager
        msgScope: msgList.scope
        context: console

    setLocalListener: (msg, cb) ->
      if msg in msgList.incoming
        incomeCallbacks[msg] = cb
])
####
# Service for parameters estimation
####
.service('estimator', [
  'qualRobEstEventMngr'
  (qualRobEstEventMngr) ->
    qualRobEstEventMngr.setLocalListener '123', (data) ->
      console.log '--- parameters estimation --> just return concatenation ---'
      data.a + data.b
])
