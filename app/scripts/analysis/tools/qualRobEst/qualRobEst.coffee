'use strict'

getData = angular.module('app.qualRobEst', [
  #The frontend modules (app.getData,app.cleanData etc) should have
  # no dependency from the backend.
  #Try to keep it as loosely coupled as possible
])

.constant(
  'msgList'
  outcome: ['123']
  income: ['234']
)

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
  'qualRobEstSb'
  'msgList'
  'estimator'
  (qualRobEstSb, msgList, estimator) ->
    (sb) ->

      qualRobEstSb.setSb sb unless !sb?

      eventManager = (msg, data) ->
        sb.publish
          msg: msgList.outcome[0]
          data: estimator.estimate data.a, data.b
          msgScope: ['qualRobEstView']

      init: (opt) ->
        console.log 'init called'

        _sb = qualRobEstSb.getSb()
        _sb.subscribe
          msg: msgList.income[0]
          listener: eventManager
          msgScope: ['qualRobEstView']

      destroy: () ->

      msgList: msgList
])
####
# Every module will have a MODULE_NAMESb() service
# For the module methods to access the sandbox object.
####
.service('qualRobEstSb', () ->
  console.log "sb in estimator"
  _sb = null
  setSb: (sb) ->
    return false if sb is undefined
    _sb = sb

  getSb: () ->
    _sb
)

.service('estimator', () ->
  console.log '--- parameters estimation --> return concatenation ---'
  estimate: (a, b) ->
    a + b
)
