'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'


module.exports = class GetDataSidebarCtrl extends BaseCtrl
  @inject '$scope',
    '$q',
    '$stateParams',
    'app_analysis_getData_msgService',
<<<<<<< HEAD
    'app_analysis_getData_jsonParser',
=======
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
    'app_analysis_getData_inputCache'

  initialize: ->
    @eventManager = @app_analysis_getData_msgService
    @inputCache = @app_analysis_getData_inputCache
<<<<<<< HEAD
    @jsonParser = @app_analysis_getData_jsonParser
=======
    # @jsonParser = @app_analysis_getData_jsonParser
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
    @jsonUrl = ''
    @flag = true
    @selected = 'getDataGrid'
    @DATA_TYPES = @eventManager.getSupportedDataTypes()

<<<<<<< HEAD
  passReceivedData: (data) ->
    if data.dataType is @DATA_TYPES.NESTED
    else
      # default data type is 2d 'flat' table
      data.dataType = @DATA_TYPES.FLAT
    @inputCache.setData data


=======
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
  # showGrid
  show: (val) ->
    switch val
      when 'grid'
        @selected = 'getDataGrid'
        @eventManager.broadcast 'getData:updateShowState', 'grid'

      when 'socrData'
        @selected = 'getDataSocrData'
        @eventManager.broadcast 'getData:updateShowState', 'socrData'

      when 'worldBank'
        @selected = 'getDataWorldBank'
        @eventManager.broadcast 'getData:updateShowState', 'worldBank'

      when 'generate'
        @selected = 'getDataGenerate'
        @eventManager.broadcast 'getData:updateShowState', 'generate'

      when 'jsonParse'
        @selected = 'getDataJson'
        @eventManager.broadcast 'getData:updateShowState', 'jsonParse'
<<<<<<< HEAD

  # getJson
  getJson: ->
    console.log @jsonUrl

    if @jsonUrl is ''
      return false

    @jsonParser.parse
      url: @jsonUrl
      type: 'worldBank'
    .then(
      (data) ->
        # Pass a message to update the handsontable div.
        # data is the formatted data which plugs into the
        # handontable.
        @passReceivedData data
        @$scope.$emit 'get Data from handsontable', inputCache
      ,
      (msg) ->
        console.log 'rejected'
      )

  # get url data
  getUrl: ->

  getGrid: ->
=======
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
