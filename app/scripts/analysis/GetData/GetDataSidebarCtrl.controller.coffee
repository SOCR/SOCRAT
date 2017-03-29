'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'


module.exports = class GetDataSidebarCtrl extends BaseCtrl
  @inject '$scope',
    '$q',
    '$stateParams',
    'app_analysis_getData_msgService',
    'app_analysis_getData_inputCache'

  initialize: ->
    @eventManager = @app_analysis_getData_msgService
    @inputCache = @app_analysis_getData_inputCache
    # @jsonParser = @app_analysis_getData_jsonParser
    @jsonUrl = ''
    @flag = true
    @selected = 'getDataGrid'
    @DATA_TYPES = @eventManager.getSupportedDataTypes()

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
