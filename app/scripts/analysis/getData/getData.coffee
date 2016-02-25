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
      outgoing: ['save data']
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
# @name: app_analysis_getData_inputCache
# @type: service
# @description: Caches data. Changes to handsontable is stored here
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
    _data = {}
    _timer = null
    _ht = null

    _getData = ->
      _data

    _saveDataToDb = (data, deferred) ->
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
        promise: deferred.promise

      sb.publish
        msg: 'save data'
        data:
          dataFrame: data
          tableName: $stateParams.projectId + ':' + $stateParams.forkId
          promise: deferred
        msgScope: ['getData']
        callback: ->
          console.log 'handsontable data updated to db'

    _setData = (data) ->
      console.log '%c inputCache set called for the project' + $stateParams.projectId + ':' + $stateParams.forkId,
        'color:steelblue'

      # TODO: fix checking existance of parameters to default table name #SOCR-140
      if data? or $stateParams.projectId? or $stateParams.forkId?
        _data = data unless data is 'edit'

        # clear any previous db update broadcast messages
        clearTimeout _timer
        _deferred = $q.defer()
        _timer = $timeout ((data, deferred) -> _saveDataToDb(data, deferred))(_data, _deferred), 1000
        true

      else
        console.log "no data passed to inputCache"
        false

    _pushData = (data) ->
      this.ht.loadData data

    get: _getData
    set: _setData
    push: _pushData
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
          # create the callback
          cb = (data, status) ->
            # obj[0] will contain meta deta
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

            # generate titles and references
            count data[1][0]
            # format data
            for c in _col
              _column.push
                data: c

            # return object
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

      # using broadcast because msg sent from rootScope
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

      # make the call using the cb we just created
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
    # get the sandbox made for this module
    # sb = getDataSb.getSb()
    # console.log 'sandbox created'
    $scope.jsonUrl = ''
    flag = true
    $scope.selected = null

    # showGrid
    $scope.show = (val) ->
      switch val
        when 'grid'
          $scope.selected = 'getDataGrid'
          if flag is true
            flag = false
            #initial the div for the first time
            data =
              default: true
              purpose: 'json'
            $scope.$emit 'update handsontable', data
          $scope.$emit 'change in showStates', 'grid'

        when 'socrData'
          $scope.selected = 'getDataSocrData'
          $scope.$emit 'change in showStates', 'socrData'

        when 'worldBank'
          $scope.selected = 'getDataWorldBank'
          $scope.$emit 'change in showStates', 'worldBank'

        when 'generate'
          $scope.selected = 'getDataGenerate'
          $scope.$emit 'change in showStates', 'generate'

        when 'jsonParse'
          $scope.selected = 'getDataJson'
          $scope.$emit 'change in showStates', 'jsonParse'

    # getJson
    $scope.getJson = ->
      console.log 123
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

    # get url data
    $scope.getUrl = ->

    $scope.getGrid = ->
])

.controller('getDataMainCtrl', [
  'app_analysis_getData_manager'
  '$scope'
  'showState'
  'app_analysis_getData_jsonParser'
  '$state'
  (getDataEventMngr, $scope, showState, jsonParser, state) ->
    console.log 'getDataMainCtrl executed'

    # available SOCR Datasets
    $scope.socrDatasets = [
      id: 'IRIS'
      name: 'Iris Flower Dataset'
    ,
      id: 'KNEE_PAIN'
      name: 'Simulated SOCR Knee Pain Centroid Location Data'
    ]
    # select first one by default
    $scope.socrdataset = $scope.socrDatasets[0]

    $scope.getWB = ->
      # default value
      if $scope.size is undefined
        $scope.size = 100
      # default option
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

          # TODO: getData module shouldn't know about controllers listening for handsontable update
          $scope.$emit 'update handsontable', data
          # Switch the accordion from getJson to grid.
          #$scope.$emit("change in showStates","grid")
        ,
        (msg) ->
          console.log 'rejected:' + msg
        )

    $scope.getSocrData = ->
      switch $scope.socrdataset.id
        # TODO: host on SOCR server
        when 'IRIS' then url = 'https://www.googledrive.com/host//0BzJubeARG-hsMnFQLTB3eEx4aTQ'
        when 'KNEE_PAIN' then url = 'https://www.googledrive.com/host//0BzJubeARG-hsLUU1Ul9WekZRV0U'
        # default option
        else url = 'https://www.googledrive.com/host//0BzJubeARG-hsMnFQLTB3eEx4aTQ'

      d3.text url,
        (dataResults) ->
          if dataResults?.length > 0
            # parse to unnamed array
            dataResults = d3.csv.parseRows dataResults
            _data =
              columnHeader: dataResults.shift()
              data: [null, dataResults]
              # purpose is helps in pin pointing which
              # handsontable directive to update.
              purpose: 'json'
            console.log 'resolved'
            # pass a message to update the handsontable div
            # data is the formatted data which plugs into the
            #  handontable.
            $scope.$emit 'update handsontable', _data
            # switch the accordion from getJson to grid
            # $scope.$emit("change in showStates","grid")
          else
            console.log 'rejected:' + msg

    $scope.getJsonByUrl = ->
      d3.json $scope.jsonUrl,
        (dataResults) ->
          if dataResults?.length > 0
            _data =
              columnHeader: dataResults.shift()
              data: [null, dataResults]
              # purpose is helps in pin pointing which
              # handsontable directive to update.
              purpose: 'json'
            console.log 'resolved'
            # pass a message to update the handsontable div
            # data is the formatted data which plugs into the
            #  handontable.
            $scope.$emit 'update handsontable', _data
            # switch the accordion from getJson to grid
            # $scope.$emit("change in showStates","grid")
          else
            console.log 'rejected:' + msg

    try
      _showState = new showState(['grid', 'socrData', 'worldBank', 'generate', 'jsonParse'], $scope)
    catch e
      console.log e.message

    # adding listeners
    $scope.$on 'update showStates', (obj, data) ->
      _showState.set data

    $scope.$on '$viewContentLoaded', ->
      console.log 'get data main div loaded'
])

# Helps sidebar accordion to keep in sync with the main div
.factory('showState', ->
  (obj, scope) ->
    if arguments.length is 0
      # return false if no arguments are provided
      return false
    _obj = obj

    # create a showState variable and attach it to supplied scope
    scope.showState = []
    for i in obj
      scope.showState[i] = true

    # index is the array key
    set: (index) ->
      if scope.showState[index]?
        for i in _obj
          if i is index
            scope.showState[index] = false
          else
            scope.showState[i] = true
)

# ###
# @name: app_analysis_getData_table2dataFrame
# @type: factory
# @description: Reformats data from input table format to the universal dataFrame object.
# ###
.factory('app_analysis_getData_dataAdaptor', [
  () ->

    # accepts handsontable table as input and returns dataFrame
    _toDataFrame = (tableData, nSpareCols, nSpareRows) ->

      # using pop to remove empty last row
      tableData.data.pop()
      # and column
      row.pop() for row in tableData.data

      # remove empty last column for header
      tableData.header.pop()

      # by default data types are not known at this step
      #  and should be defined at Clean Data step
      colTypes = ('symbolic' for [1...tableData.nCols - nSpareCols])

      dataFrame =
        data: tableData.data
        header: tableData.header
        nRows: tableData.nRows - nSpareRows
        nCols: tableData.nCols - nSpareCols

    _toHandsontable = () ->
      # TODO: implement for poping up data when coming back from analysis tabs

    toDataFrame: _toDataFrame
    toHandsontable: _toHandsontable
])


.directive 'handsontable', [
  'app_analysis_getData_inputCache'
  'app_analysis_getData_dataAdaptor'
  '$exceptionHandler'
  (inputCache, dataAdaptor, $exceptionHandler) ->
    restrict: 'E'
    transclude: true

    # to the name attribute on the directive element.
    # the template for the directive.
    template: "<div class='hot-scroll-container' style='height: 300px'></div>"

    #the controller for the directive
    controller: ($scope) ->

    replace: true #replace the directive element with the output of the template.

    # the link method does the work of setting the directive
    #  up, things like bindings, jquery calls, etc are done in here
    #  It is run before the controller
    link: (scope, elem, attr) ->

      N_SPARE_COLS = 1
      N_SPARE_ROWS = 1
      DEFAULT_ROW_HEIGHT = 24

      # useful to identify which handsontable instance to update
      scope.purpose = attr.purpose

      # retrieves data from handsontable object
      _format = (obj) ->

        data = obj.getData()
        header = obj.getColHeader()
        nCols = obj.countCols()
        nRows = obj.countRows()

        table =
          data: data
          header: header
          nCols: nCols
          nRows: nRows

      scope.update = (evt, arg) ->
        console.log 'handsontable: update called'

        currHeight = elem.height()

        #check if data is in the right format
#        if arg? and typeof arg.data is 'object' and typeof arg.columns is 'object'
        if arg? and typeof arg.data is 'object'
          obj =
            data: arg.data[1]
#            startRows: Object.keys(arg.data[1]).length
#            startCols: arg.columns.length
            colHeaders: arg.columnHeader
#            columns: arg.columns
            minSpareRows: N_SPARE_ROWS
            minSpareCols: N_SPARE_COLS
            allowInsertRow: true
            allowInsertColumn: true
        else if arg.default is true
          obj =
            data: [
              ['Copy', 'paste', 'your', 'data', 'here']
            ]
            colHeaders: true
            minSpareRows: N_SPARE_ROWS
            minSpareCols: N_SPARE_COLS
            allowInsertRow: true
            allowInsertColumn: true
            rowHeaders: false
        else
          $exceptionHandler
            message: 'handsontable configuration is missing'

        obj['change'] = true
        obj['afterChange'] = (change, source) ->
          # saving data to be globally accessible.
          #  only place from where data is saved before DB: inputCache.
          #  onSave, data is picked up from inputCache.
          if source is 'loadData' or 'paste'
            ht = $(this)[0]
            tableData = _format ht
            dataFrame = dataAdaptor.toDataFrame tableData, N_SPARE_COLS, N_SPARE_ROWS
            inputCache.set dataFrame
            ht.updateSettings
              height: Math.max currHeight, ht.countRows() * DEFAULT_ROW_HEIGHT
          else
            inputCache.set source

        try
          # hook for pushing data changes to handsontable
          # TODO: get rid of tight coupling :-/
          ht = elem.handsontable obj
          window['inputCache'] = inputCache.ht = $(ht[0]).data('handsontable')
        catch e
          $exceptionHandler e

      # subscribing to handsontable update.
      scope.$on attr.purpose + ':load data to handsontable', scope.update
      console.log 'handsontable directive linked'
]
