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
  (qualRobEstEventMngr) ->
    (sb) ->

      msgList = qualRobEstEventMngr.getMsgList()
      qualRobEstEventMngr.setSb sb unless !sb?

      init: (opt) ->
        console.log 'qualRobEst init called'
        qualRobEstEventMngr.listenToIncomeEvents()

      destroy: () ->

      msgList: msgList
])
####
# Every module will have a MODULE_NAMEEventMngr() service
# which provides messaging with core
####
.service('qualRobEstEventMngr', [
  'estimator'
  (estimator) ->
    sb = null

    msgList =
      outcome: ['234']
      income: ['123']
      scope: ['qualRobEst']

    eventManager = (msg, data) ->
      sb.publish
        msg: msgList.outcome[0]
        data: estimator.estimate data.a, data.b
        msgScope: msgList.scope

    setSb: (_sb) ->
      return false if _sb is undefined
      sb = _sb

    getMsgList: () ->
      msgList

    listenToIncomeEvents: () ->
      console.log 'subscribed for ' + msgList.income[0]
      sb.subscribe
        msg: msgList.income[0]
        listener: eventManager
        msgScope: msgList.scope
        context: console
])

.service('estimator', () ->
  estimate: (a, b) ->
    console.log '--- parameters estimation --> return concatenation ---'
    a + b
)
