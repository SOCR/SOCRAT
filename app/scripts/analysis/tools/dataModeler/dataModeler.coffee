'use strict'

dataModeler = angular.module('app.dataModeler', [
  'socr.dataModels'
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
    console.log "config block of dataModeler"
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
.factory('dataModeler', [
  'dataModelerEventMngr'
  (dataModelerEventMngr) ->
    (sb) ->

      msgList = dataModelerEventMngr.getMsgList()
      dataModelerEventMngr.setSb sb unless !sb?

      init: (opt) ->
        console.log 'dataModeler init called'
        dataModelerEventMngr.listenToIncomeEvents()

      destroy: () ->

      msgList: msgList
])
####
# Every module will have a MODULE_NAMEEventMngr() service
# which provides messaging with core
####
.service('dataModelerEventMngr', [
  'modeler'
  (modeler) ->
    sb = null

    msgList =
      outcome: ['data modeled']
      income: ['model data']
      scope: ['dataModeler']

    eventManager = (msg, data) ->
      sb.publish
        msg: msgList.outcome[0]
        data: modeler.model data
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

.service('modeler',[
  'binomialDataModel'
  (binomialDataModel) ->
    model: (obj) ->
      # pick up data using the forkName
      # if data absent, then send a UI message
      # choose the model
      # Using promise, perform the modelling
      # update results and charts tab.

      console.log '--- MODELLING ---'
      x = [1,2,3,4,2,1,4]
      y = [1,3,5,2,1,5,5,2]
      console.log binomialDataModel
      obj
])

# Modeler Class service. All data models are
# objects created from this.
.service('modelerClass', ()->
  modelType = null
  



)
