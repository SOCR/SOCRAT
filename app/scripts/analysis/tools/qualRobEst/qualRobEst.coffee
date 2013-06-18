'use strict'

getData = angular.module('app.qualRobEst', [
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

# ###
# getDataViewCtrl is the ctrl that talks to the view.
# ###
.controller('qualRobEstSidebarCtrl', [
  '$scope'
  'qualRobEstSb'
  ($scope, qualRobEstSb) ->
    console.log 'qualRobEstSidebarCtrl executed'
    _sb = qualRobEstSb.getSb()
    $scope.firstNumber = '1'
    $scope.secondNumber = '2'
    $scope.sumNumbers = () ->
      console.log '123'
      _sb.publish
        msg: '123'
        data: $scope.firstNumber + $scope.secondNumber
        msgScope: ['qualRobEst']
])

.controller('qualRobEstMainCtrl', [
 '$scope'
 'qualRobEstSb'
 ($scope, qualRobEstSb) ->
   console.log 'qualRobEstMainCtrl executed'
   _sb = qualRobEstSb.getSb()
   _sb.subscribe
     msg: '234'
     listener: (m, data) -> $scope.sum = data
     msgScope: ['qualRobEst']
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
.factory('qualRobEst', ['qualRobEstSb', (qualRobEstSb) ->
  (sb) ->
    qualRobEstSb.setSb(sb) unless !sb?

    init: (opt) ->
      console.log 'init called'

    destroy: () ->

    msgList:
      outcome: ['123']
      income: ['234']
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
