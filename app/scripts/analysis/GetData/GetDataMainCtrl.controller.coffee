'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'
require 'handsontable/dist/handsontable.full.css'
require 'imports?Handsontable=handsontable/dist/handsontable.full.js!ngHandsontable/dist/ngHandsontable.js'

module.exports = class GetDataMainCtrl extends BaseCtrl
  @inject '$scope',
    '$state',
    'app_analysis_getData_dataService',
    'app_analysis_getData_showState',
    'app_analysis_getData_jsonParser',
    'app_analysis_getData_dataAdaptor',
    'app_analysis_getData_inputCache',
    '$timeout'

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
    @interface = {}

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

    @$scope.$watch( =>
      @$scope.mainArea.file
    , (file) =>
      if file?
        dataResults = @d3.csv.parseRows file
        data = @dataAdaptor.toDataFrame dataResults
        @passReceivedData data
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
  ,
    id: 'CURVEDNESS_AD'
    name: 'Neuroimaging study of 27 of Global Cortical Surface Curvedness (27 AD, 35 NC and 42 MCI)'
  ,
    id: 'PCV_SPECIES'
    name: 'Neuroimaging study of Prefrontal Cortex Volume across Species'
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
      when 'IRIS' then url = 'datasets/iris.csv'
      when 'KNEE_PAIN' then url = 'datasets/knee_pain_data.csv'
      when 'CURVEDNESS_AD' then url='datasets/Global_Cortical_Surface_Curvedness_AD_NC_MCI.csv'
      when 'PCV_SPECIES' then url='datasets/Prefrontal_Cortex_Volume_across_Species.csv'
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
