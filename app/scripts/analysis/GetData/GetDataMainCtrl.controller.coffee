'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'
require 'handsontable/dist/handsontable.full.css'
require 'imports?Handsontable=handsontable/dist/handsontable.full.js!ngHandsontable/dist/ngHandsontable.js'
require 'ng-file-upload'

module.exports = class GetDataMainCtrl extends BaseCtrl
  @inject '$scope',
    '$state',
    'app_analysis_getData_dataService',
    'app_analysis_getData_showState',
    'app_analysis_getData_jsonParser',
    'app_analysis_getData_dataAdaptor',
    'app_analysis_getData_inputCache',
    '$timeout'
    'Upload'

  initialize: ->
    @d3 = require 'd3'
    # rename deps
    @dataManager = @app_analysis_getData_dataService
    @showStateService = @app_analysis_getData_showState
    @inputCache = @app_analysis_getData_inputCache
    @jsonParser = @app_analysis_getData_jsonParser
    @dataAdaptor = @app_analysis_getData_dataAdaptor

    # get initial settings
    @dataLoadedFromDb = false
    @DATA_TYPES = @dataManager.getDataTypes()
    @states = ['grid', 'socrData', 'worldBank', 'generate', 'jsonParse']
    @defaultState = @states[0]
    @dataType = @DATA_TYPES.FLAT if @DATA_TYPES.FLAT?
    @socrdataset = @socrDatasets[0]
    @colHeaders = on
    @file = null

    # init table
    @tableSettings =
      rowHeaders: on
      stretchH: "all"
      contextMenu: on
      onAfterChange: (changes, source) =>
        # check if table is empty
        if @tableData?
          # don't save data if just loaded
          if @dataLoadedFromDb
            @dataLoadedFromDb = false
          else
            data = @dataAdaptor.toDataFrame @tableData, @colHeaders
            @inputCache.setData data

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
        @stateService.set @defaultState

    # adding listeners
    @$scope.$on 'getData:updateShowState', (obj, data) =>
      @stateService.set data
      console.log @showState
      # all data are flat, except for arbitrary JSON files
      @dataType = @DATA_TYPES.FLAT if data in @states.filter (x) -> x isnt 'jsonParse'

    @$scope.$on '$viewContentLoaded', ->
      console.log 'get data main div loaded'

    @$scope.$watch( =>
      @$scope.mainArea.file
    , (file) =>
      console.log 'file detected'
      @upload file
    )

  ## Other instance methods

  passReceivedData: (data) ->
    if data.dataType is @DATA_TYPES.NESTED
      @dataType = @DATA_TYPES.NESTED
      # save to db
      @inputCache.setData data
    else
      # default data type is 2d 'flat' table
      data.dataType = @DATA_TYPES.FLAT
      @dataType = @DATA_TYPES.FLAT

      # update table
      @$timeout =>
        @colHeaders = data.header
        @tableData = data.data
        console.log 'ht updated'

  # available SOCR Datasets
  socrDatasets: [
    id: 'IRIS'
    name: 'Iris Flower Dataset'
  ,
    id: 'KNEE_PAIN'
    name: 'Simulated SOCR Knee Pain Centroid Location Data'
  ]

  getWB: ->
    # default value
    if @size is undefined
      @size = 100
    # default option
    if @option is undefined
      @option = '4.2_BASIC.EDU.SPENDING'

    url = 'http://api.worldbank.org/countries/indicators/' + @option +
        '?per_page=' + @size + '&date=2011:2011&format=jsonp' +
        '&prefix=JSON_CALLBACK'

    @jsonParser.parse
      url: url
      type: 'worldBank'
    .then(
      (data) =>
        console.log 'resolved'
        @passReceivedData data
      ,
      (msg) ->
        console.log 'rejected:' + msg
      )

  getSocrData: ->
    switch @socrdataset.id
      # TODO: host on SOCR server
      when 'IRIS' then url = 'https://www.googledrive.com/host//0BzJubeARG-hsMnFQLTB3eEx4aTQ'
      when 'KNEE_PAIN' then url = 'https://www.googledrive.com/host//0BzJubeARG-hsLUU1Ul9WekZRV0U'
      # default option
      else url = 'https://www.googledrive.com/host//0BzJubeARG-hsMnFQLTB3eEx4aTQ'

    @d3.text url,
      (dataResults) =>
        if dataResults?.length > 0
          # parse to unnamed array
          dataResults = @d3.csv.parseRows dataResults
          data = @dataAdaptor.toDataFrame dataResults
          @passReceivedData data
        else
          console.log 'rejected:' + msg

  getJsonByUrl: (type) ->
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

  upload: (file) ->
    if file and !file.$error
      @Upload.upload(
        url: '/#/getData',
        data:
          file: file
      ).then (resp) =>
        console.log 'File uploaded'
        dataResults = @d3.csv.parseRows resp
        data = @dataAdaptor.toDataFrame dataResults
        @passReceivedData data
      , null, (evt) =>
        progressPercentage = parseInt 100.0 * evt.loaded / evt.total
        @log = 'progress: ' + progressPercentage +
            '% ' + evt.config.data.file.name + '\n' + @log
