'use strict'

getData = angular.module('app.getData', [
  #The frontend modules (app.getData,app.cleanData etc) should have
  # no dependency from the backend.
  #Try to keep it as loosely coupled as possible
  'ngGrid'
  'ui.bootstrap'
])

.config([
  # ###
  # Config block is for module initialization work.
  # services, providers from ng module (such as $http, $resource)
  # can be injected here.
  # services, providers defined in this module CANNOT be injected
  # in the config block.
  # config block is run before their initialization.
  # ###
    ()->
      console.log "config block of getData"
])

# jsonParser parses the json url input by the user.
# @returns :
#
.factory('jsonParser',[
  '$http'
  ($http)->
    (opts)->
#      return null if not opts?
#      # test json : https://graph.facebook.com/search?q=ucla
#      $http.jsonp(
#        "https://graph.facebook.com/search?q=ucla&callback=JSON_CALLBACK"
#        )
#        .success((data,status) ->
#          #save the data in a tempCache
#          # db.save(response,'tempCache')
#          console.log data
#          console.log status
#
#
#          #execute any callbacks present
#          #opts.cb() ?opts.cb
#          #return the jsonp data
#          return data
#        ).error((data,status)->
#            console.log data
#        )
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
#    $scope.gridCollapsed = false
#    $scope.wbCollapsed = false
#    $scope.generateCollapsed = false
#    $scope.urlCollapsed = false
#    $scope.jsonCollapsed = false

  #showGrid
    $scope.showGrid = ->
      console.log("showGrid called")
      $scope.$emit("change in showStates","grid")
      #hide all divs and show only grid

  #getJson
    $scope.getJson = ->
      #console.log("getJson called")
      #console.log $scope.jsonUrl
      try
        data = jsonParser
          url:$scope.jsonUrl
          cb:() ->
            #sb.publish "json input successful", "local"
      #send a message within the module
        #sb.publish 'json url successfully parsed', data, 'local'
      catch e
        console.log e.message
        #console.log e.stack
      return

  #show WorldBank interface
    $scope.showWBInterface = ->
      console.log "getWBInterface"
      $scope.$emit("change in showStates","worldBank")

  #get url data
    $scope.getUrl = ->

  #save state. For safety lets run it after every edit just like google docs.
    $scope.saveState = ->

  ])

.controller('getDataMainCtrl', [
  '$scope'
  'showState'
  ($scope,showState)->
    console.log 'getDataMainCtrl executed'

    $scope.defaultData = [
      {name: "Moroni", age: 50}
      {name: "Tiancum", age: 43}
      {name: "Jacob", age: 27}
      {name: "Nephi", age: 29}
      {name: "Enos", age: 34}
    ]

    $scope.gridOptions =
      data:"defaultData"
      enableCellSelection: true
      canSelectRows: false
      enableCellEdit:true
      displaySelectionCheckbox: false
      enableFocusedCellEdit: true
      columnDefs: [
        field: 'name'
        displayName: 'Name'
      ,
        field:'age'
        displayName:'Age'
      ]
    try
      _showState = new showState(["grid","worldBank"],$scope)
    catch e
      console.log e.message

    $scope.$on("update showStates",(obj,data)->
      #console.log "start state:"
      #console.log $scope.showState
      #console.log data
      _showState.set(data)
    )

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

.factory("showState", ->
  (obj,scope)->
    if arguments.length is 0
      #return false if no arguments are provided
      return false
    _obj = obj
    # create a showState variable and attach it to supplied scope
    scope.showState = new Array()
    for i in obj
      scope.showState[i] = true
    # index is the array key.
    set : (index)->
      if scope.showState[index]?
        for i in _obj
          if i is index
            scope.showState[index] = false
          else
            scope.showState[i]=true
        #console.log "final state"
        #console.log scope.showState
)


