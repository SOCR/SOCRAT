'use strict'

getData = angular.module('app_analysis_getData', [
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

.factory('app_analysis_getData_constructor', [
  'app_anaylsis_getData_manager'
  (manager) ->
    (sb) ->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'getData init invoked'

      destroy: () ->

      msgList: _msgList
])

.factory('app_analysis_getData_manager', [
  () ->
    _sb = null

    _msgList =
      outgoing: ['take data']
      incoming: ['get data']
      scope: ['getData']

    _setSb = (sb) ->
      _sb = sb

    _getSb = () ->
      _sb

    _getMsgList = () ->
      _msgList

    getSb: _getSb
    setSb: _setSb
    getMsgList: _getMsgList
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
  'app_analysis_getData_manager'
  '$scope'
  'jsonParser'
  (manager,$scope,jsonParser)->

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
  'app_analysis_getData_manager'
  '$scope'
  (manager,$scope)->
    console.log 'getDataCtrl executed'
])



