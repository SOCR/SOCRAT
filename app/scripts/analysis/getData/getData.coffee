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
      return null if not opts?
      # test json : https://graph.facebook.com/search?q=ucla
      opts.url ="http://api.worldbank.org/countries/indicators/2.4_OOSC.RATE?"+
      "per_page=100&date=1960:2013&format=jsonp&prefix=JSON_CALLBACK"
      #opts.url="http://api.worldbank.org/countries/indicators/4.2_BASIC.EDU"+
      #".SPENDING?per_page=100&date=2011:2011&format=jsonp&prefix=JSON_CALLBACK"
      switch opts.type
        when "worldBank"
          #create the callback
          cb = (data,status)->
            # obj[0] will contain meta deta.
            #obj[1] will contain array
            _col = []
            _column = []
            tree = []
            count = (obj)->
              try
                if typeof obj is "object" and obj isnt null
                  for key in Object.keys obj
                    console.log tree
                    tree.push key
                    console.log key
                    count obj[key]
                    tree.pop()
                else
                  _col.push tree.join('.')
                console.log _col
                return _col
              catch e
                console.log e.message
              return true
            #generate titles and references
            count data[1][0]
            # format data
            for c in _col
              _column.push
                data:c
            console.log data
            console.log _column
            #returned object
# Testing the results on a div
#            container = $(".worldBank")
#            try
#              container.handsontable(
#                data: data[1]
#                startRows: Object.keys(data[1]).length
#                startCols: _column.length
#                colHeaders: _col
#                columns:_column
#                minSpareRows: 1
#              )
#            catch e
#              console.log e.message

        else
          #default implementation
          cb = (data,status)->
            console.log data
            return data

      $http.jsonp(
        opts.url
        )
        .success(cb)
        .error((data,status)->
            console.log data
            console.log status
        )
      #.done(opts.cb)
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
    #console.log 'sandbox created'
#    $scope.gridCollapsed = false
#    $scope.wbCollapsed = false
#    $scope.generateCollapsed = false
#    $scope.urlCollapsed = false
#    $scope.jsonCollapsed = false
    $scope.jsonUrl = "url.."
#    try
#      $scope.$watch "jsonUrl", ->
#        console.log "yo"
#    catch e
#      console.log e.message

  #showGrid
    $scope.showGrid = ->
      #console.log("showGrid called")
      $scope.$emit("change in showStates","grid")
      #hide all divs and show only grid

  #getJson
    $scope.getJson = ->
      #console.log("getJson called")
      console.log $scope.jsonUrl
      if $scope.jsonUrl is ""
        return false
      try
        jsonParser
          url:$scope.jsonUrl
          type:"json"
#         cb:(obj) ->
#            sb.publish
#              msg:"json input successful"
#              msgScope:["local"]
#              data:obj
#              cb:()->
#                console.log "callback executed successfully!"
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


