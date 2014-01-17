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
# jsonParser gets json based on url
#
#
.factory('jsonParser',[
  '$http'
  ($http)->
    (opts)->
      return null if not opts?
      # test json : https://graph.facebook.com/search?q=ucla
      $http.jsonp(opts.url+"&callback=JSON_CALLBACK")
        .success((data,status) ->
          #save the data in a tempCache
          # db.save(response,'tempCache')
          console.log data
          console.log status


          #execute any callbacks present
          #opts.cb() ?opts.cb
          #return the jsonp data
          return data
        ).error((data,status)->

        )
])

# ###
# getDataViewCtrl is the ctrl that talks to the view.
# ###
.controller('getDataSidebarCtrl', [
  '$scope'
  'getDataSb'
  'jsonParser'
  ($scope,getDataSb,jsonParser)->

    #get the sandbox made for this module
    #sb = getDataSb.getSb()
    console.log 'sandbox created'

    #getJson
    $scope.getJson=()->
      console.log("test")
      console.log $scope.jsonUrl
      try
        data = jsonParser
          url:$scope.jsonUrl
          cb:() ->
            #sb.publish "json input successful", "local"
      #send a message within the module
        #sb.publish 'json url successfully parsed', data, 'local'
      catch e
        console.log e.message
        console.log e.stack
      return

    $scope.getUrl = ()->

    $scope.getGrid = ()->
    return
  ])

.controller('getDataMainCtrl', [
  '$scope'
  ($scope)->
    #$scope.msg = "selvam"
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


