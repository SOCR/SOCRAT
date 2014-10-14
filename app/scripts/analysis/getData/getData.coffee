'use strict'

getData = angular.module('app_analysis_getData', [
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
    () ->
      console.log 'config block of getData'
])

.factory('app_analysis_getData_constructor', [
  'app_analysis_getData_manager'
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
      outgoing: ['take data', 'handsontable updated']
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

# ###
# @name : app_analysis_getData_inputCache
# @type : service
# @description:Caches data. Changes to handsontable is stored here
# and synced after some time. Changes in db is heard and reflected on
# handsontable.
# ###
.service('app_analysis_getData_inputCache',[
  'app_analysis_getData_manager'
  '$q'
  '$stateParams'
  '$rootScope'
  '$timeout'
  (manager, $q, $stateParams, $rootScope, $timeout) ->

    sb = manager.getSb()
    _data = []
    _timer = null
    ret = {}
    ret.ht = null

    ret.get = ->
      _data

    ret.set = (data) ->
      console.log '%c inputCache set called', 'color:steelblue'
      if data?
        _data = data unless data is 'edit'

        #clear any previous db update broadcast messages.
        clearTimeout _timer

        deferred = $q.defer()

        _timer =  $timeout ( ->

          $rootScope.$broadcast 'app:push notification',
            initial:
              msg: 'Data is being saved in the database...'
              type: 'alert-info'
            success:
              msg: 'Successfully loaded data into database'
              type: 'alert-success'
            failure:
              msg: 'Error in Database'
              type: 'alert-error'

          sb.publish
            msg: 'handsontable updated'
            data: [_data, $stateParams.projectId, $stateParams.forkId, deferred]
            msgScope: ['getData']

        ), 4000

      else
        false

    ret.push = (data) ->
      this.ht.loadData data
    ret
])


# jsonParser gets json based on url
#
# @type: factory
# @description: jsonParser parses the json url input by the user.
# @dependencies : $q, $rootscope, $http
.factory('app_analysis_getData_jsonParser', [
  '$http'
  '$q'
  '$rootScope'
  ($http, $q, $rootScope) ->
    (opts) ->
      return null if not opts?

      # test json : https://graph.facebook.com/search?q=ucla
      deferred = $q.defer()
      console.log deferred.promise

      switch opts.type
        when 'worldBank'
          #create the callback
          cb = (data, status) ->
            # obj[0] will contain meta deta.
            # obj[1] will contain array
            _col = []
            _column = []
            tree = []

            count = (obj) ->
              try
                if typeof obj is 'object' and obj isnt null
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
                data: c

            #return object
            data: data
            columns: _column
            columnHeader: _col
            # purpose is helps in pin pointing which
            # handsontable directive to update.
            purpose: 'json'
        else
          #default implementation
          cb = (data, status) ->
            console.log data
            return data

      # using broadcast because msg sent from rootScope.
      $rootScope.$broadcast 'app:push notification',
        initial:
          msg: 'Asking worldbank...'
          type: 'alert-info'
        success:
          msg: 'Successfully loaded data.'
          type: 'alert-success'
        failure:
          msg: 'Error in the call.'
          type: 'alert-error'
        promise: deferred.promise

      #make the call using the cb we just created
      $http.jsonp(
        opts.url
        )
        .success((data, status) ->
          console.log 'deferred.promise'
          formattedData = cb data, status
          deferred.resolve formattedData
          #$rootScope.$apply()
        )
        .error((data, status) ->
            console.log 'promise rejected'
            deferred.reject 'promise is rejected'
        )
      deferred.promise
])

# ###
# getDataSidebarCtrl is the ctrl that talks to the view.
# ###
.controller('getDataSidebarCtrl', [
  '$q'
  '$scope'
  'app_analysis_getData_manager'
  'app_analysis_getData_jsonParser'
  '$stateParams'
  'app_analysis_getData_inputCache'
  ($q, $scope, getDataEventMngr, jsonParser, $stateParams, inputCache) ->
    #get the sandbox made for this module
    #sb = getDataSb.getSb()
    #console.log 'sandbox created'
    $scope.jsonUrl = 'url..'
    flag = true

    #showGrid
    $scope.show = (val) ->
      switch val
        when 'grid'
          if flag is true
            flag = false
            #initial the div for the first time
            data =
              default: true
              purpose: 'json'
            $scope.$emit 'update handsontable', data
          $scope.$emit 'change in showStates', 'grid'

        when 'worldBank'
          $scope.$emit 'change in showStates', 'worldBank'

        when  'generate'
          $scope.$emit 'change in showStates', 'generate'

  #getJson
    $scope.getJson = ->
      console.log $scope.jsonUrl

      if $scope.jsonUrl is ''
        return false

      jsonParser
        url: $scope.jsonUrl
        type: 'worldBank'
      .then(
        (data) ->
          # Pass a message to update the handsontable div.
          # data is the formatted data which plugs into the
          # handontable.
          $scope.$emit 'update handsontable', data
          $scope.$emit 'get Data from handsontable', inputCache
        ,
        (msg) ->
          console.log 'rejected'
        )

    #get url data
    $scope.getUrl = ->

    $scope.getGrid = ->
    return
])

.controller('getDataMainCtrl', [
  'app_analysis_getData_manager'
  '$scope'
  'showState'
  'app_analysis_getData_jsonParser'
  '$state'
  (getDataEventMngr, $scope, showState, jsonParser, state) ->
    console.log 'getDataMainCtrl executed'

    $scope.getWB = ->
      #default value
      if $scope.size is undefined
        $scope.size = 100
      #default option
      if $scope.option is undefined
        $scope.option = '4.2_BASIC.EDU.SPENDING'

      url = 'http://api.worldbank.org/countries/indicators/' + $scope.option +
          '?per_page=' + $scope.size + '&date=2011:2011&format=jsonp' +
          '&prefix=JSON_CALLBACK'

      jsonParser
        url: url
        type: 'worldBank'
      .then(
        (data) ->
          console.log 'resolved'
          # Pass a message to update the handsontable div.
          # data is the formatted data which plugs into the
          # handontable.
          $scope.$emit 'update handsontable', data
          # Switch the accordion from getJson to grid.
          #$scope.$emit("change in showStates","grid")
        ,
        (msg) ->
          console.log 'rejected:' + msg
        )

    try
      _showState = new showState(['grid', 'worldBank', 'generate'], $scope)
    catch e
      console.log e.message

    # Adding Listeners
    $scope.$on 'update showStates', (obj, data) ->
      _showState.set data

    $scope.$on '$viewContentLoaded', ->
      console.log 'get data main div loaded'
])


####
# Every module will have a MODULE_NAMEEventMngr() service
# which provides messaging with core
####
.service('app_analysis_getData_eventMngr', [
  '$rootScope'
  ($rootScope) ->
    sb = null
    sum = ''

    msgList =
      outcome: ['save table']
      income:
        'handsontable updated':
          method: (args...) ->
            args
          outcome: 'save table'
      scope: ['getData']

    eventManager = (msg, data) ->
      try
        _data = msgList.income[msg].method.apply null, data
        #last item in data is a promise. #TODO: need to add a check
        promise = data[data.length - 1]
        promise.resolve _data if _data isnt false
      catch e
        console.log e.message
        promise.reject e.message

      sb.publish
        msg: msgList.income[msg].outcome
        data: _data
        msgScope: msgList.scope

    setSb: (_sb) ->
      return false if _sb is undefined
      sb = _sb

    getMsgList: () ->
      msgList

    getSb: ->
      sb

    listenToIncomeEvents: () ->
      for msg of msgList.income
        console.log 'subscribed for ' + msg
        sb.subscribe
          msg: msg
          listener: eventManager
          msgScope: msgList.scope
          context: console

])

# Helps sidebar accordion to keep in sync with the main div.
.factory('showState', ->
  (obj, scope) ->
    if arguments.length is 0
      #return false if no arguments are provided
      return false
    _obj = obj

    # create a showState variable and attach it to supplied scope
    scope.showState = []
    for i in obj
      scope.showState[i] = true

    # index is the array key.
    set: (index) ->
      if scope.showState[index]?
        for i in _obj
          if i is index
            scope.showState[index] = false
          else
            scope.showState[i] = true
        #console.log "final state"
        #console.log scope.showState
)


.factory('html2json', ($http) ->
  (url, cb) ->
    # Use url to get html.
    # parse html to find tables
    # use jQuery plugin to get jsons for all tables.
    return false unless url?

    $http.get(url).success(
      #search for tables
      (data) ->
        console.log 'success'
        # parser = new DOMparser()
        # dom = parser.parseFromString(data)
        # tables = dom.getElementsByTagName("table")
        if data? and typeof data is 'string'
          obj = $(data)
          res = obj.tableToJSON()
        #table-to-json
        #returned data is used to compute data, coulumns, columnHeader
        #compute the res obj
        cb(res)
      )

)

.directive 'handsontable', [
  'app_analysis_getData_inputCache'
  '$exceptionHandler'
  (inputCache, $exceptionHandler) ->
    restrict: 'E'
    transclude:true
    # to the name attribute on the directive element.

    #the template for the directive.
    template: "<div></div>"
    #the controller for the directive
    controller: ($scope) ->

    replace: true #replace the directive element with the output of the template.

    #the link method does the work of setting the directive
    # up, things like bindings, jquery calls, etc are done in here
    # It is run before the controller
    link: (scope, elem, attr) ->
      # useful to identify which handsontable instance to update
      scope.purpose = attr.purpose
      # Update the table with the scope values
      _format = (data, cols) ->
        if arguments.length is 2
          table = []
          cols = cols || []

          for c in cols
            obj = {}
            obj.name = c.data
            obj.values = []
            path = c.data.split '.'

            for d in data
              i = 1
              temp = d[path[0]]

              while i < path.length
                if temp[path[i]]?
                  temp = temp[path[i]]
                  i++
                else
                  temp = null
                  break

              if temp?
                if typeof temp is 'number'
                  obj.type = 'numeric'
                obj.values.push temp

            #save the column obj in the table.
            table.push obj
        table

      scope.update = (evt, arg) ->
        console.log 'handsontable: update called'
        #check if data is in the right format
        if arg? and typeof arg.data is 'object' and typeof arg.columns is 'object'
          obj =
            data: arg.data[1]
            startRows: Object.keys(arg.data[1]).length
            startCols: arg.columns.length
            colHeaders: arg.columnHeader
            columns:arg.columns
            minSpareRows: 1

        else if arg.default is true
          obj =
            data: [
              ['Copy', 'paste', 'your', 'data', 'here']
            ]
            colHeaders: true
            minSpareRows: 5
        else
          $exceptionHandler
            message: 'handsontable configuration is missing'

        obj['change'] = true
        obj['afterChange'] = (change, source) ->
          #saving data to be globally accessible.
          # only place from where data is saved before DB: inputCache.
          # onSave, data is picked up from inputCache.
          if source is 'loadData'
            inputCache.set _format($(this)[0].getData(),arg.columns)
          else
            inputCache.set source
        try
          #hook for pushing data changes to handsontable.
          #Tight coupling :-/
          ht = elem.handsontable obj
          window['inputCache'] = inputCache.ht = $(ht[0]).data('handsontable')
        catch e
          $exceptionHandler e

      # subscribing to handsontable update.
      scope.$on attr.purpose + ':load data to handsontable', scope.update
      console.log 'handsontable directive linked'
]
