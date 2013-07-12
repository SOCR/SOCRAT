'use strict'

qualRobEstView = angular.module('app.qualRobEstView', [
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
    console.log "config block of qualRobEstView"
])

# ###
# getDataViewCtrl is the ctrl that talks to the view.
# ###
.controller('qualRobEstViewSidebarCtrl', [
  '$scope'
  'qualRobEstViewEventMngr'
  ($scope, qualRobEstViewEventMngr) ->
    console.log 'qualRobEstViewSidebarCtrl executed'

    $scope.realParams = '[1,1,1]'
    $scope.outcomeDim = '1'
    $scope.outcomeLevels = '3'
    $scope.numObserv = '1000'
    $scope.noiseLevel = '0.2'
    $scope.estParam = '0.5'



    $scope.sumNumbers = () ->
      qualRobEstViewEventMngr.sendNumbers(
        $scope.firstNumber
        $scope.secondNumber
      )

])

.controller('qualRobEstViewMainCtrl', [
  '$scope'
  'qualRobEstViewEventMngr'
  ($scope, qualRobEstViewEventMngr) ->
    console.log 'qualRobEstViewMainCtrl executed'
#    $scope.sum = qualRobEstViewEventMngr.sum
    $scope.$on 'newSum', (event, pushData) ->
      $scope.sum = pushData
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
.factory('qualRobEstView', [
  'qualRobEstViewEventMngr'
  (qualRobEstViewEventMngr) ->
    (sb) ->

      msgList = qualRobEstViewEventMngr.getMsgList()
      qualRobEstViewEventMngr.setSb sb unless !sb?

      init: (opt) ->
        console.log 'qualRobEstView init called'
        qualRobEstViewEventMngr.listenToIncomeEvents()

      destroy: () ->

      msgList: msgList
])
####
# Every module will have a MODULE_NAMEEventMngr() service
# which provides messaging with core
####
.service('qualRobEstViewEventMngr', [
  '$rootScope'
  ($rootScope) ->
    sb = null
    sum = ''

    msgList =
      outcome: ['111']
      income: ['000']
      scope: ['qualRobEstView']

    eventManager = (msg, data) ->
      $rootScope.$broadcast 'newSum', data

    sendNumbers: (a, b) ->
      sb.publish
        msg: msgList.outcome[0]
        data:
          a: a
          b: b
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