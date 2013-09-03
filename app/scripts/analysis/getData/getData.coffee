'use strict'

getData = angular.module('app.getData', [
  #The frontend modules (app.getData,app.cleanData etc) should have
  # no dependency from the backend.
  #Try to keep it as loosely coupled as possible
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
  '$q'
  '$rootScope'
  ($http,$q,$rootScope)->
    (opts)->
      return null if not opts?
      # test json : https://graph.facebook.com/search?q=ucla
      deferred = $q.defer()
      console.log deferred.promise
    # opts.url = "http://api.worldbank.org/countries/indicators/2.4_OOSC.RATE?"+
    # "per_page=100&date=1960:2013&format=jsonp&prefix=JSON_CALLBACK"
    #opts.url="http://api.worldbank.org/countries/indicators/4.2_BASIC.EDU"+
    #".SPENDING?per_page=100&date=2011:2011&format=jsonp&prefix=JSON_CALLBACK"
      switch opts.type
        when "worldBank"
          #create the callback
          cb = (data,status)->
            # obj[0] will contain meta deta.
            # obj[1] will contain array
            _col = []
            _column = []
            tree = []
            count = (obj)->
              try
                if typeof obj is "object" and obj isnt null
                  for key in Object.keys obj
                    tree.push key
                    count obj[key]
                    tree.pop()
                else
                  _col.push tree.join('.')
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
            #return object
            data:data
            columns:_column
            columnHeader:_col
            # purpose is helps in pin pointing which
            # handsontable directive to update.
            purpose:"json"
        else
          #default implementation
          cb = (data,status)->
            console.log data
            return data
      #make the call using the cb we just created
      $http.jsonp(
        opts.url
        )
        .success((data,status)->
          console.log "deferred.promise"
          formattedData = cb(data,status)
          deferred.resolve(formattedData)
          $rootScope.$apply()
        )
        .error((data,status)->
            console.log "promise rejected"
            deferred.reject("promise is rejected")
        )
      deferred.promise
])

# ###
# getDataSidebarCtrl is the ctrl that talks to the view.
# ###
.controller('getDataSidebarCtrl', [
  '$scope'
  'getDataEventMngr'
  'jsonParser'
  ($scope,getDataEventMngr,jsonParser,$stateParams)->
    #get the sandbox made for this module
    #sb = getDataSb.getSb()
    #console.log 'sandbox created'
    $scope.jsonUrl = "url.."

  #showGrid
    $scope.showGrid = ->
      #console.log("showGrid called")
      $scope.$emit("change in showStates","grid")
      #hide all divs and show only grid
      data =
        default:true
        purpose:"json"
      $scope.$emit("update handsontable",data)

  #getJson
    $scope.getJson = ->
      console.log $scope.jsonUrl
      if $scope.jsonUrl is ""
        return false
      jsonParser
        url:$scope.jsonUrl
        type:"worldBank"
      .then(
        (data)->
          # Pass a message to update the handsontable div.
          # data is the formatted data which plugs into the
          # handontable.
          $scope.$emit("update handsontable",data)
          # Switch the accordion from getJson to grid.
          $scope.$emit("change in showStates","grid")
        ,
        (msg)->
          console.log "rejected"
        )

  #show WorldBank interface
    $scope.showWBInterface = ->
      console.log "getWBInterface"
      $scope.$emit("change in showStates","worldBank")

  #get url data
    $scope.getUrl = ->

  #save state. For safety lets run it after every edit just like google docs.
    $scope.saveState = ->

  #generate
    $scope.showGenerate = ->
      $scope.$emit("change in showStates","generate")

  #save data
    $scope.save = (data)->
      if $stateParams.projectId? and $stateParams.forkId?
        tname = $stateParams.projectId+":"+$stateParams.forkId+":"+"default"
        # if data?
        #   database.create data,tname
      else
        #sent error message
  ])

.controller('getDataMainCtrl', [
  '$scope'
  'showState'
  'jsonParser'
  ($scope,showState,jsonParser)->
    console.log 'getDataMainCtrl executed'

    $scope.getWB = ->
      #default value
      if $scope.size is undefined
        $scope.size = 100
      #default option
      if $scope.option is undefined
        $scope.option = '4.2_BASIC.EDU.SPENDING'
      url = "http://api.worldbank.org/countries/indicators/"+$scope.option+
      "?per_page="+$scope.size+"&date=2011:2011&format=jsonp"+
      "&prefix=JSON_CALLBACK"
      jsonParser
        url:url
        type:"worldBank"
      .then(
        (data)->
          console.log "resolved"
          # Pass a message to update the handsontable div.
          # data is the formatted data which plugs into the
          # handontable.
          $scope.$emit("update handsontable",data)
          # Switch the accordion from getJson to grid.
          $scope.$emit("change in showStates","grid")
        ,
        (msg)->
          console.log "rejected"
        )

    try
      _showState = new showState(["grid","worldBank","generate"],$scope)
    catch e
      console.log e.message

    # Adding Listeners
    $scope.$on "update showStates", (obj,data)->
      _showState.set(data)

    $scope.$on "$viewContentLoaded", ->
      console.log "get data main div loaded"
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
.factory('getData',[
  'getDataEventMngr'
  (getDataEventMngr)->
    (sb)->
      msgList = getDataEventMngr.getMsgList()
      getDataEventMngr.setSb sb unless !sb?
      init: (opt)->
        console.log "getData init called"
        getDataEventMngr.listenToIncomeEvents()
      
      destroy: ()->

      msgList:msgList
])

####
# Every module will have a MODULE_NAMEEventMngr() service
# which provides messaging with core
####
.service('getDataEventMngr', [
  '$rootScope'
  ($rootScope) ->
    sb = null
    sum = ''

    msgList =
      outcome: ['get111']
      income: ['get000']
      scope: ['getData']

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

# Helps sidebar accordion to keep in sync with the main div.
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

.factory("html2json", ($http)->
  (url,cb)->
    # Use url to get html.
    # parse html to find tables
    # use jQuery plugin to get jsons for all tables.
    return false unless url?
 
    $http.get(url).success(
      #search for tables
      (data)->
        console.log "success"
        # parser = new DOMparser()
        # dom = parser.parseFromString(data)
        # tables = dom.getElementsByTagName("table")
        if data? and typeof data is "string"
          obj = $(data)
          res = obj.tableToJSON()

        #table-to-json
        #returned data is used to compute data, coulumns, columnHeader
        #compute the res obj
        cb(res)
      )
 
)
 
.directive "handsontable", ->
  restrict: "E"
  transclude:true
  # to the name attribute on the directive element.
  
  #the template for the directive.
  template: "<div></div>"
  
  #the controller for the directive
  controller: ($scope,html2json) ->
    #$scope.$on("load data to handsontable",$scope.update)
  replace: true #replace the directive element with the output of the template.
  
  #the link method does the work of setting the directive
  # up, things like bindings, jquery calls, etc are done in here
  # It is run before the controller
  link: (scope, elem, attr) ->
    # useful to identify which handsontable instance to update
    scope.purpose = attr.purpose

    # Update the table with the scope values
    scope.update = (evt,arg) ->
      console.log "update called"
      #check if data is in the right format
      if arg? and typeof arg.data is "object" and typeof arg.columns is "object"
        elem.handsontable
          data: arg.data[1]
          startRows: Object.keys(arg.data[1]).length
          startCols: arg.columns.length
          colHeaders: arg.columnHeader
          columns:arg.columns
          minSpareRows: 1
        
      else if arg.default is true
        elem.handsontable(
          data: [
            ["Copy", "paste", "your", "data", "here"],
          ]
          colHeaders: true
          minSpareRows: 5
        )
      else
        #raise a warning using exceptionhandler
    # subscribing to handsontable update.
    scope.$on(attr.purpose+":load data to handsontable",scope.update)
    console.log "handsontable directive linked"

