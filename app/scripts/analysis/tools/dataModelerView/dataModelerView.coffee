'use strict'

dataModelerView = angular.module('app.dataModelerView', [
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
    console.log "config block of dataModelerView"
])

# ###
# getDataViewCtrl is the ctrl that talks to the view.
# ###
.controller('dataModelerViewSidebarCtrl', [
  '$scope'
  'dataModelerViewEventMngr'
  ($scope, dataModelerViewEventMngr) ->
    console.log 'dataModelerViewSidebarCtrl executed'

    $scope.socrModels = ['Binomial','Beta','Normal']
    $scope.forkName = ''
    $scope.selectedModel = ''
    $scope.userParams = ''

    $scope.model = () ->
      dataModelerViewEventMngr.model(
        $scope.selectedModel
        $scope.forkName
        $scope.userParams
      )

])

.controller('dataModelerViewMainCtrl', [
  '$scope'
  'dataModelerViewEventMngr'
  ($scope, dataModelerViewEventMngr) ->
    console.log 'dataModelerViewMainCtrl executed'
#    $scope.sum = dataModelerViewEventMngr.sum
    $scope.$on 'model data', (event, pushData) ->
      $scope.show = pushData
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
.factory('dataModelerView', [
  'dataModelerViewEventMngr'
  (dataModelerViewEventMngr) ->
    (sb) ->

      msgList = dataModelerViewEventMngr.getMsgList()
      dataModelerViewEventMngr.setSb sb unless !sb?

      init: (opt) ->
        console.log 'dataModelerView init called'
        dataModelerViewEventMngr.listenToIncomeEvents()

      destroy: () ->

      msgList: msgList
])
####
# Every module will have a MODULE_NAMEEventMngr() service
# which provides messaging with core
####
.service('dataModelerViewEventMngr', [
  '$rootScope'
  ($rootScope) ->
    sb = null
    sum = ''

    msgList =
      outcome: ['model data']
      income: ['000']
      scope: ['dataModelerView']

    eventManager = (msg, data) ->
      $rootScope.$broadcast 'model data', data

    model: (a, b, c) ->
      sb.publish
        msg: msgList.outcome[0]
        data:
          model: a
          forkName: b
          userParams: c
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

    sum: sum
])