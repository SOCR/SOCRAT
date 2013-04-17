'use strict'

getData = angular.module('app.getData', [
  #The frontend modules (app.getData,app.cleanData etc) should have
  # no dependency from the backend.
  #Try to keep it as loosely coupled as possible
])

.config([
  # ###
  # Config block is for module initialization work.
  # services, providers from ng module (such as $http, $resource)
  # can be injected here.
  # services, providers in this module CANNOT be injected in the config block.
  # config block is run before their initialization.
  # ###
    ()->
      console.log "config block of getData"
])
  # ###
  # getDataViewCtrl is the ctrl that talks to the view.
  # ###
.controller('getDataViewCtrl', [
  '$scope'
  'getDataSb'
  ($scope,getDataSb)->
    $scope.msg=''
    console.log "getDataViewCtrl executed"
    sb = getDataSb.getSb()
    console.log sb
  ])

.controller('getDataCtrl', [
  '$scope'
  ($scope)->
    console.log 'getDataCtrl executed'
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
.factory('getData',['getDataSb', (getDataSb)->
  (sb) ->
    getDataSb.setSb(sb) unless !sb?
    init: ()->
    destroy: ()->
])
####
# Every module will have a MODULE_NAMESb() service
# For the module methods to access the sandbox object.
####
.service('getDataSb', ()->
  console.log "sb"
  _sb = null
  setSb:(sb)->
    return false if sb is undefined
    _sb = sb

  getSb:()->
    _sb
)

