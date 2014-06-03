'use strict'

qualRobEst = angular.module('app_qualRobEst', [
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
  'qualRobEst_manager'
  'estimator'
  (qualRobEstMngr, estimator) ->
    (sb) ->
      console.log sb
      qualRobEstMngr.setSb sb unless !sb?
      _msgList = qualRobEstMngr.getMsgList()

      init: (opt) ->
        console.log 'qualRobEst init invoked'
        estimator.initEstimator(sb)

      destroy: () ->

      msgList: _msgList
])
####
# Service for parameters estimation
####
.service('estimator', [
#  'qualRobEst_manager'
#  (qualRobEstMngr) ->
  () ->
    console.log 'estimator executed'
    _initEstimator = (sb) ->
#      sb = qualRobEstMngr.getSb()
      sb.subscribe
        msg: 'add numbers'
        listener: (msg, data) ->
          console.log '--- parameters estimation --> just return concatenation ---'
          console.log data
          sum = data.a + data.b
          sb.publish
            msg: 'numbers added'
            data: sum
            msgScope: ['qualRobEst']
        msgScope: ['qualRobEst']

    initEstimator: _initEstimator
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

    getSb: () ->
      _sb

    getMsgList: () ->
      _msgList
])
