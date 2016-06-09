'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class GetDataMainCtrl extends BaseCtrl
  @inject '$scope',
    '$state',
    'app_analysis_getData_msgService',
    'app_analysis_getData_showState',
    'app_analysis_getData_jsonParser',
    'app_analysis_getData_dataAdaptor',
    'app_analysis_getData_inputCache'

  initialize: ->
#    DATA_TYPES = eventManager.getSupportedDataTypes()
#    $scope.DATA_TYPES = DATA_TYPES
#    $scope.dataType = ''

  passReceivedData: (data) ->
    if data.dataType is DATA_TYPES.NESTED
      @dataType = DATA_TYPES.NESTED
      inputCache.set data
    else
      # default data type is 2d 'flat' table
      data.dataType = DATA_TYPES.FLAT
      @dataType = DATA_TYPES.FLAT
      # pass a message to update the handsontable div
      # data is the formatted data which plugs into the
      #  handontable.
      # TODO: getData module shouldn't know about controllers listening for handsontable update
      @$scope.$emit 'update handsontable', data

  # available SOCR Datasets
  socrDatasets: [
    id: 'IRIS'
    name: 'Iris Flower Dataset'
  ,
    id: 'KNEE_PAIN'
    name: 'Simulated SOCR Knee Pain Centroid Location Data'
  ]
  # select first one by default
#  socrdataset: @socrDatasets[0]

  getWB = ->
    # default value
    if @size is undefined
      @size = 100
    # default option
    if @option is undefined
      @option = '4.2_BASIC.EDU.SPENDING'

    url = 'http://api.worldbank.org/countries/indicators/' + @option +
        '?per_page=' + @size + '&date=2011:2011&format=jsonp' +
        '&prefix=JSON_CALLBACK'

    jsonParser
      url: url
      type: 'worldBank'
    .then(
      (data) ->
        console.log 'resolved'
        passReceivedData data
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
          passReceivedData _data
        else
          console.log 'rejected:' + msg

  getJsonByUrl: (type) ->
    d3.json @jsonUrl,
      (dataResults) ->
        # check that data object is not empty
        if dataResults? and Object.keys(dataResults)?.length > 0
          res = dataAdaptor.jsonToFlatTable dataResults
          # check if JSON contains "flat data" - 2d array
          if res
            _data =
              columnHeader: if res.length > 1 then res.shift() else []
              data: [null, res]
              # purpose is helps in pin pointing which
              # handsontable directive to update.
              purpose: 'json'
              dataType: DATA_TYPES.FLAT
          else
            _data =
              data: dataResults
              dataType: DATA_TYPES.NESTED
          passReceivedData _data
        else
          console.log 'GETDATA: request failed'

#  try
#    @showState = new showState(['grid', 'socrData', 'worldBank', 'generate', 'jsonParse'], @)
#  catch e
#    console.log e.message
#
#  # adding listeners
#  @$scope.$on 'update showStates', (obj, data) ->
#    @showState.set data
#    # TODO: fix this workaround for displaying copy-paste table
#    @dataType = DATA_TYPES.FLAT if data is 'grid'
#
#  @$scope.$on '$viewContentLoaded', ->
#    console.log 'get data main div loaded'
