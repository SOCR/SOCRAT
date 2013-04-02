'use strict'

getData = angular.module('app.getData', [
  #The frontend modules (app.getData,app.cleanData etc) should have
  # no dependency from the backend.
  #Try to keep it as loosely coupled as possible
])

.config([
  # ###
  #Config block is for module initialization work.
  # services, providers from ng module (such as $http, $resource)
  # can be injected here.
  # services, providers in this module CANNOT be injected in the config block.
  # config block is run before their initialization.
  # ###
    ()->
      console.log "config block of getData"
])

.controller('getDataViewCtrl', [
  '$scope'
  'getData'
  ($scope,sb)->
    $scope.msg=''
    #sb = getDataSb()
  ])

.controller('getDataCtrl', [
  '$scope'
  ($scope)->
    console.log 'yo'
])

.factory('getData', ->
  (sb) ->
    _sb = null
    setSb:(sb)->
      return false if sb is undefined
      _sb = sb
)
.service('sb', ()->
  console.log "sb"
)
