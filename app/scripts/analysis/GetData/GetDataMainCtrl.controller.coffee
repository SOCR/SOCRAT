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
    '$compile',
    '$window',
    '$q',
    '$sce',
    '$rootScope',
    '$http'

  initialize: ->
    @d3 = require 'd3'
    # rename deps
    @dataService = @app_analysis_getData_dataService
    @showStateService = @app_analysis_getData_showState
    @inputCache = @app_analysis_getData_inputCache
    @dataAdaptor = @app_analysis_getData_dataAdaptor
    @socrData = @app_analysis_getData_socrDataConfig
    # get initial settings
    @LARGE_DATA_SIZE = 20000 # number of cells in table
    @dataLoadedFromDb = false
    @largeData = false
    @maxRows = 1000
    @DATA_TYPES = @dataService.getDataTypes()
    @states = @showStateService.getOptionKeys()

    @WBDatasets = [
        "name":"Out of School Children rate",
        "key": "2.4_OOSC.RATE",
      ,
        "key":"4.2_BASIC.EDU.SPENDING",
        "name":"Education Spending"
    ]
    @startYear = "2010"
    @endYear = "2017"
    @jsonURL = {
      url : "",
      dataPath: ""
    }
    @defaultState = @states[0]
    @dataType = @DATA_TYPES.FLAT if @DATA_TYPES.FLAT?
    @socrDatasets = @socrData.getNames()
    @socrdataset = @socrDatasets[0]

    @colHeadersLabels = ['A', 'B', 'C', 'D', 'E']

    @colStats     = []
    @colHistograms = []
    @colStatsTooltipHTML = []

    @colStatsToolTipHTMLGenerator = (index) =>

      stats = @colStats[index] || {min:0,max:0,mean:0,sd:0}
      mean = if stats.mean? then stats.mean.toFixed(2) else 0
      sd = if stats.sd? then stats.sd.toFixed(2) else 0
      markup = """<span>Min:#{stats.min},Max:#{stats.max},Mean:#{mean},SD:#{sd}</span>"""
      @$sce.trustAsHtml markup

    @customHeaderRenderer = (colIndex, th) =>
      if @colHeadersLabels[colIndex]? && colIndex!=false

        @colStatsTooltipHTML[colIndex] = @colStatsToolTipHTMLGenerator colIndex

        # Tooltip position "right" for the first 2 columns
        tooltipPos = if colIndex < 2 then "right" else "left"

        # Code to place tooltip on <div> inside <th>
        elem = th.querySelector('div')
        elem.parentNode.removeChild(elem)
        angular.element(th).append @$compile(
          "<div class='relative' uib-tooltip-html='mainArea.colStatsTooltipHTML["+colIndex+"]' tooltip-trigger='mouseenter' tooltip-placement='"+tooltipPos+"'><span class='colHeader columnSorting'>"+@colHeadersLabels[colIndex]+"\n\n</span></div>"
        )(@$scope)
        ## Code to place tooltip on <span> inside <th>
        # angular.element(th.querySelector('span')).append @$compile('<span uib-tooltip="Tesasdajkdasjkdbasjkdbasjkbdaskjdbt" tooltip-trigger="mouseenter" tooltip-placement="right">'+ @colHeadersLabels[colIndex]+'</span>')(@$rootScope)

        ## Code to place tooltip on <th> by replacing a new <th>
        # angular.element(th).replaceWith @$compile(
        #   "<th uib-tooltip-html='mainArea.tooltip' tooltip-trigger='mouseenter' tooltip-placement='right'><div class='relative'><span class='colHeader columnSorting'>"+@colHeadersLabels[colIndex]+"</span></div></th>"
        # )(@$scope)
      else
        # "<span uib-popover='Test' popover-trigger='focus'> "+ @colHeadersLabels[colIndex]+"</span>"
        ""

    @file = null
    @interface = {}

    # init table
    @tableSettings =
      rowHeaders: on
      colHeaders: true
      stretchH: "all"
      contextMenu: on
      onAfterChange: @saveTableData
      onAfterCreateCol: @saveTableData
      onAfterCreateRow: @saveTableData
      onAfterRemoveCol: @saveTableData
      onAfterRemoveRow: @saveTableData
      afterGetColHeader: @customHeaderRenderer

    try
      @stateService = @showStateService.create @states, @
    catch e
      console.warn e.message

    @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType?
        if obj.dataFrame.dataType is @DATA_TYPES.FLAT
          @dataLoadedFromDb = true
          @dataType = obj.dataFrame.dataType
          @$timeout =>
            @colHeadersLabels = obj.dataFrame.header
            @tableData = obj.dataFrame.data

            newDataFrame = @dataAdaptor.transformArraysToObject obj.dataFrame
            newDataFrame = @dataAdaptor.enforceTypes newDataFrame
            @dataService.getSummary newDataFrame
            .then (resp)=>
              if resp? and resp.dataFrame? and resp.dataFrame.data?
                @colStats = resp.dataFrame.data

            for k,v of newDataFrame.types
              colValues = @dataAdaptor.getColValues newDataFrame,k
              @colHistograms[ newDataFrame.header.indexOf(k) ] = colValues.data

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
        @colHeadersLabels = ['A', 'B', 'C', 'D', 'E']
        @stateService.set @defaultState

    # adding listeners
    @$scope.$on 'getData:updateShowState', (obj, data) =>
      @stateService.set data
      # console.log @showState
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

  formatNumber: (i) ->
    return Math.round(i * 100)/100;

  checkDataSize: (nRows, nCols) ->
    if nRows and nCols and nRows * nCols > @LARGE_DATA_SIZE
        @largeData = true
        @maxRows = Math.floor(@LARGE_DATA_SIZE / @colHeadersLabels.length) - 1
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

  ###
    @return {Promise}
  ###
  saveTableData: () =>
    # check if table is empty
    if @tableData?
      # don't save data if just loaded
      if @dataLoadedFromDb
        @dataLoadedFromDb = false
      else
        @dataAdaptor.toDataFrame @tableData, @colHeadersLabels
        .then( (dataFrame)=>
          @checkDataSize dataFrame.nRows, dataFrame.nCols
          @inputCache.setData dataFrame

          # @todo: This transformation should be happening in dataAdaptor.toDataFrame
          # need to check if handsontable can render arrayOfObjects
          newDataFrame = @dataAdaptor.transformArraysToObject dataFrame
          newDataFrame = @dataAdaptor.enforceTypes newDataFrame
          @dataService.getSummary newDataFrame
          .then (resp)=>
            if resp? and resp.dataFrame? and resp.dataFrame.data?
              @colStats = resp.dataFrame.data

          for k,v of newDataFrame.types
            colValues = @dataAdaptor.getColValues newDataFrame,k
            @colHistograms[ newDataFrame.header.indexOf(k) ] = colValues.data

            ## Code to get histogram values from Datalib
            # ((newDataFrame,k)=>
            #   @dataService.getHistogram @dataAdaptor.getColValues newDataFrame,k
            #   .then( (res)=>
            #     @colHistograms[ newDataFrame.header.indexOf(k)] = res.dataFrame.data
            #     console.log "HISTOGRAM VALUES",@colHistograms
            #   )
            # )(newDataFrame, k)
        )


  ###
  @param {Object} - instance of DataFrame
  @desc -
  ###
  passReceivedData: (dataFrame) ->
    if not @dataAdaptor.isValidDataFrame dataFrame
      throw Error "invalid data frame"

    # @todo: This transformation should be happening in dataAdaptor.toDataFrame
    # need to check if handsontable can render arrayOfObjects
    newDataFrame = @dataAdaptor.transformArraysToObject dataFrame
    newDataFrame = @dataAdaptor.enforceTypes newDataFrame
    @dataService.getSummary newDataFrame
    .then (resp) =>
      if resp? and resp.dataFrame? and resp.dataFrame.data?
        @colStats = resp.dataFrame.data
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
            @colHeadersLabels = dataFrame.header

  getWBDataset: ->
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
          @dataAdaptor.toDataFrame httpResponseObject.data[1]
          .then( (dataFrame)=>
            @passReceivedData dataFrame
          )
        else
          deferred.reject "http request failed!"
      )
    .catch( (err) =>
      throw err
    )

  getSocrDataset: ->
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

          @dataAdaptor.toDataFrame dataResults, headers
          .then( (dataFrame)=>
            @passReceivedData dataFrame
          )
        else
          console.log 'GETDATA: request failed'

  openSocrDescription: ->
    @$window.open @socrdataset.desc, '_blank'
    true

  getJsonURLDataset: (type) ->
    # TODO: replace d3 with datalib
    @$http.get(@jsonURL.url)
    .then(
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
    )
