'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'
require 'handsontable/dist/handsontable.full.css'
require 'imports?Handsontable=handsontable/dist/handsontable.full.js!ng-handsontable/dist/ngHandsontable.js'

module.exports = class GetDataMainCtrl extends BaseCtrl
  @inject '$scope',
    '$state',
    'app_analysis_getData_dataService',
    'app_analysis_getData_showState',
    'app_analysis_getData_dataAdaptor',
    'app_analysis_getData_inputCache',
    'app_analysis_getData_socrDataConfig',
    '$timeout',
    '$window',
    '$q',
    '$rootScope',
    '$http'

  initialize: ->
    @d3 = require 'd3'
    # rename deps
    @dataManager = @app_analysis_getData_dataService
    @showStateService = @app_analysis_getData_showState
    @inputCache = @app_analysis_getData_inputCache
    @dataAdaptor = @app_analysis_getData_dataAdaptor
    @socrData = @app_analysis_getData_socrDataConfig

    # get initial settings
    @LARGE_DATA_SIZE = 20000 # number of cells in table
    @dataLoadedFromDb = false
    @largeData = false
    @maxRows = 1000
    @DATA_TYPES = @dataManager.getDataTypes()
    @states = ['grid', 'socrData', 'worldBank', 'generate', 'jsonParse']
    @WBDatasets = [
        "name":"Out of School Children rate",
        "key": "2.4_OOSC.RATE",
      ,
        "key":"4.2_BASIC.EDU.SPENDING",
        "name":"Education Spending"
    ]
    @startYear = "2010"
    @endYear = "2017"

    @defaultState = @states[0]
    @dataType = @DATA_TYPES.FLAT if @DATA_TYPES.FLAT?
    @socrDatasets = @socrData.getNames()
    @socrdataset = @socrDatasets[0]
    @colHeaders = on
    @file = null
    @interface = {}

    # init table
    @tableSettings =
      rowHeaders: on
      stretchH: "all"
      contextMenu: on
      onAfterChange: @saveTableData
      onAfterCreateCol: @saveTableData
      onAfterCreateRow: @saveTableData
      onAfterRemoveCol: @saveTableData
      onAfterRemoveRow: @saveTableData

    try
      @stateService = @showStateService.create @states, @
      console.log @stateService
    catch e
      console.log e.message

    @dataManager.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType?
        if obj.dataFrame.dataType is @DATA_TYPES.FLAT
          @dataLoadedFromDb = true
          @dataType = obj.dataFrame.dataType
          @$timeout =>
            @colHeaders = obj.dataFrame.header
            @tableData = obj.dataFrame.data
        else
          # TODO: add processing for nested object
          console.log 'NESTED DATASET'
      else
        # initialize default state as spreadsheet view
        # handsontable automatically binds to @tableData
        @tableData = [
          ['Copy', 'paste', 'your', 'data', 'here']
        ]
        # manually create col header since ht doesn't bind default value to scope
        @colHeaders = ['A', 'B', 'C', 'D', 'E']
        @stateService.set @defaultState

    # adding listeners
    @$scope.$on 'getData:updateShowState', (obj, data) =>
      @stateService.set data
      console.log @showState
      # all data are flat, except for arbitrary JSON files
      @dataType = @DATA_TYPES.FLAT if data in @states.filter (x) -> x isnt 'jsonParse'

    @$scope.$on '$viewContentLoaded', ->
      console.log 'get data main div loaded'

    # watch drag-n-drop file
    @$scope.$watch( =>
      @$scope.mainArea.file
    , (file) =>
      if file?
        # TODO: replace d3 with datalib
        dataResults = @d3.csv.parseRows file
        data = @dataAdaptor.toDataFrame dataResults
        @passReceivedData data
    )

  ## Other instance methods

  checkDataSize: (nRows, nCols) ->
    if nRows and nCols and nRows * nCols > @LARGE_DATA_SIZE
        @largeData = true
        @maxRows = Math.floor(@LARGE_DATA_SIZE / @colHeaders.length) - 1
    else
        @largeData = false
        @maxRows = 1000

  subsampleData: () ->
    subsample = (@getRandomInt(0, @tableData.length - 1) for i in [0..@maxRows])
    data = (@tableData[idx] for idx in subsample.sort((a, b) => (a - b)))
    @$timeout =>
      @tableData = data
      @largeData = false
      @saveTableData()

  getRandomInt: (min, max) ->
    Math.floor(Math.random() * (max - min)) + min

  saveTableData: () =>
    # check if table is empty
    if @tableData?
      # don't save data if just loaded
      if @dataLoadedFromDb
        @dataLoadedFromDb = false
      else
        data = @dataAdaptor.toDataFrame @tableData, @colHeaders
        @checkDataSize data.nRows, data.nCols
        @inputCache.setData data
  ###
  @param {Object} - instance of DataFrame
  @desc -
  ###
  passReceivedData: (dataFrame) ->
    if not @dataAdaptor.isValidDataFrame dataFrame
      throw Error "invalid data frame"

    if dataFrame.dataType is @DATA_TYPES.NESTED
      @dataType = @DATA_TYPES.NESTED
      @checkDataSize dataFrame.nRows, dataFrame.nCols
      # save to db
      @inputCache.setData dataFrame
    else
      # default data type is 2d 'flat' table
      dataFrame.dataType = @DATA_TYPES.FLAT
      @dataType = @DATA_TYPES.FLAT
      # update table
      @inputCache.setData dataFrame
      @$timeout =>
        @tableData = dataFrame.data
        @colHeaders = dataFrame.header

  getWB: ->
    # default value
    if @size is undefined
      @size = 100
    # default option
    if @option is undefined
      @option = '4.2_BASIC.EDU.SPENDING'

    url = 'http://api.worldbank.org/countries/indicators/' + @option+
        '?per_page=' + @size+ '&date='+ @startYear+':'+@endYear+'&format=jsonp' +
        '&prefix=JSON_CALLBACK'

    deferred = @$q.defer()
    # using broadcast because msg sent from rootScope
    @$rootScope.$broadcast 'app:push notification',
      initial:
        msg: 'Asking worldbank...'
        type: 'alert-info'
      success:
        msg: 'Successfully loaded data.'
        type: 'alert-success'
      failure:
        msg: 'Error!'
        type: 'alert-error'
      promise: deferred.promise

    @$http.jsonp(
      url
    )
    .then(
      (httpResponseObject) =>
        if httpResponseObject.status == 200
          deferred.resolve httpResponseObject.data
          dataFrame = @dataAdaptor.toDataFrame httpResponseObject.data[1]
          @passReceivedData dataFrame
        else
          deferred.reject "http request failed!"
      )
    .catch( (err) =>
      throw err
    )

  getSocrData: ->
    url = @socrData.getUrlByName @socrdataset.id
    # default option
    url = 'https://www.googledrive.com/host//0BzJubeARG-hsMnFQLTB3eEx4aTQ' unless url

    # TODO: replace d3 with datalib
    @d3.text url,
      (dataResults) =>
        if dataResults?.length > 0
          # parse to unnamed array
          dataResults = @d3.csv.parseRows dataResults
          headers = dataResults.shift()
          data = @dataAdaptor.toDataFrame dataResults, headers
          @passReceivedData data
        else
          console.log 'GETDATA: request failed'

  openSocrDescription: ->
    @$window.open @socrdataset.desc, '_blank'
    true

  getJsonByUrl: (type) ->
    # TODO: replace d3 with datalib
    @d3.json @jsonUrl,
      (dataResults) =>
        # check that data object is not empty
        if dataResults? and Object.keys(dataResults)?.length > 0
          res = @dataAdaptor.jsonToFlatTable dataResults
          # check if JSON contains "flat data" - 2d array
          if res
            _data = @dataAdaptor.toDataFrame res
          else
            _data =
              data: dataResults
              dataType: @DATA_TYPES.NESTED
          @passReceivedData _data
        else
          console.log 'GETDATA: request failed'
