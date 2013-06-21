'use strict'

getData = angular.module('app.qualRobEstView', [
  #The frontend modules (app.getData,app.cleanData etc) should have
  # no dependency from the backend.
  #Try to keep it as loosely coupled as possible
])

.constant(
  'msgList'
  outcome: ['000']
  income: ['111']
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
    console.log "config block of qualRobEstView"
])

# ###
# getDataViewCtrl is the ctrl that talks to the view.
# ###
.controller('qualRobEstViewSidebarCtrl', [
  '$scope'
  'msgList'
  'qualRobEstViewSb'
  ($scope, msgList, qualRobEstViewSb) ->
    console.log 'qualRobEstViewSidebarCtrl executed'
    _sb = qualRobEstViewSb.getSb()
    $scope.firstNumber = '1'
    $scope.secondNumber = '2'
    $scope.sumNumbers = () ->
      _sb.publish
        msg: msgList.outcome[0]
        data: $scope.firstNumber + $scope.secondNumber
        msgScope: ['qualRobEstView']
])

.controller('qualRobEstViewMainCtrl', [
  '$scope'
  'msgList'
  'qualRobEstViewSb'
  ($scope, msgList, qualRobEstViewSb) ->
    console.log 'qualRobEstViewMainCtrl executed'
    _sb = qualRobEstViewSb.getSb()

    _sb.subscribe
      msg: msgList.income[0]
      listener: (m, data) -> $scope.sum = data
      msgScope: ['qualRobEstView']
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
  'qualRobEstViewSb'
  'msgList'
  (qualRobEstViewSb, msgList) ->
    (sb) ->

      qualRobEstViewSb.setSb sb unless !sb?

      init: (opt) ->
        console.log 'init called'

      destroy: () ->

      msgList: msgList
])
####
# Every module will have a MODULE_NAMESb() service
# For the module methods to access the sandbox object.
####
.service('qualRobEstViewSb', () ->
  console.log "sb in estimator"
  _sb = null
  setSb: (sb) ->
    return false if sb is undefined
    _sb = sb

  getSb: () ->
    _sb
)