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
#  '$scope'
  'qualRobEstViewMngr'
  ($scope, qualRobEstViewMngr) ->
    console.log 'qualRobEstViewSidebarCtrl executed'

    $scope.realParams = '[1,1,1]'
    $scope.outcomeDim = '1'
    $scope.outcomeLevels = '3'
    $scope.numObserv = '1000'
    $scope.noiseLevel = '0.2'
    $scope.estParam = '0.5'

#    $scope.sumNumbers = () ->
#      qualRobEstViewMngr.sendNumbers(
#        $scope.outcomeDim
#        $scope.outcomeLevels
#      )

])

.controller('qualRobEstViewMainCtrl', [
#  '$scope'
  'qualRobEstViewMngr'
  ($scope, qualRobEstViewMngr) ->
    console.log 'qualRobEstViewMainCtrl executed'
#    $scope.sum = qualRobEstViewEventMngr.sum
#    $scope.$on 'newSum', (event, pushData) ->
#      $scope.sum = pushData
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
  'qualRobEstView_manager'
  (qualRobEstViewMngr) ->
    (sb) ->
      qualRobEstViewMngr.setSb sb unless !sb?

      init: (opt) ->
        console.log 'qualRobEstView init invoked'
        # TODO: need to use this or just setLocalListener (which will subscribe automatically inside eventMngr)?
        # TODO: i.e. does module listen for incoming events if components didn't ask about it?
        #        sb.subscribeForEvents(
        #          qualRobEstViewMngr.msgList.incoming
        #          qualRobEstViewMngr.eventManager
        #        ) unless !sb?

        destroy: () ->

      msgList: qualRobEstViewMngr.msgList
])
####
# Every module will have a MODULE_NAMEEventMngr() service
# which provides messaging with core
####
.service('qualRobEstViewMngr', [
  () ->
    _sb = null

    _msgList =
      outgoing: ['add numbers']
      incoming: ['numbers added']
      scope: ['qualRobEstView']

    setSb: (sb) ->
      return false if sb is undefined
      _sb = sb

    getMsgList: () ->
      _msgList

    sb: _sb
])