'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class GetDataSidebarCtrl extends BaseCtrl
  @inject '$scope',
    '$q',
    '$stateParams',
    'app_analysis_getData_msgService',
    'app_analysis_getData_jsonParser',
    'app_analysis_getData_inputCache'

  initialize: ->
#    @eventManager = @app_analysis_getData_msgService
#    @inputCache = @app_analysis_getData_inputCache
#    @jsonParser = @app_analysis_getData_jsonParser
#    @$scope.jsonUrl = ''
#    flag = true
#    @$scope.selected = null
#    @DATA_TYPES = @eventManager.getSupportedDataTypes()

  passReceivedData: (data) ->
    if data.dataType is DATA_TYPES.NESTED
      @inputCache.set data
    else
      # default data type is 2d 'flat' table
      data.dataType = DATA_TYPES.FLAT
      # pass a message to update the handsontable div
      # data is the formatted data which plugs into the
      #  handontable.
      # TODO: getData module shouldn't know about controllers listening for handsontable update
      @$scope.$emit 'update handsontable', data

  # showGrid
  show: (val) ->
    switch val
      when 'grid'
        @selected = 'getDataGrid'
        if flag is true
          flag = false
          #initial the div for the first time
          data =
            default: true
            purpose: 'json'
          passReceivedData data
        $scope.$emit 'change in showStates', 'grid'

      when 'socrData'
        @selected = 'getDataSocrData'
        @$scope.$emit 'change in showStates', 'socrData'

      when 'worldBank'
        @selected = 'getDataWorldBank'
        @$scope.$emit 'change in showStates', 'worldBank'

      when 'generate'
        @selected = 'getDataGenerate'
        @$scope.$emit 'change in showStates', 'generate'

      when 'jsonParse'
        @selected = 'getDataJson'
        $scope.$emit 'change in showStates', 'jsonParse'

  # getJson
  getJson: ->
    console.log @jsonUrl

    if @jsonUrl is ''
      return false

    jsonParser
      url: @jsonUrl
      type: 'worldBank'
    .then(
      (data) ->
        # Pass a message to update the handsontable div.
        # data is the formatted data which plugs into the
        # handontable.
        passReceivedData data
        $scope.$emit 'get Data from handsontable', inputCache
      ,
      (msg) ->
        console.log 'rejected'
      )

  # get url data
  getUrl: ->

  getGrid: ->
