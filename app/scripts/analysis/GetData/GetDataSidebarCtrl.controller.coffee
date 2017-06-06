'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'


module.exports = class GetDataSidebarCtrl extends BaseCtrl
  @inject '$scope',
    'app_analysis_getData_msgService',
    'app_analysis_getData_showState'

  initialize: ->
    @eventManager = @app_analysis_getData_msgService
    @selected = null
    @DATA_TYPES = @eventManager.getSupportedDataTypes()
    @options = @app_analysis_getData_showState.getOptions()

  show: (val) ->
    matchedOption = @options.filter (option)->
      if option.key == val
        return option

    if matchedOption? and matchedOption[0]?
      @selected = matchedOption[0].key
      @eventManager.broadcast 'getData:updateShowState',matchedOption[0].key
