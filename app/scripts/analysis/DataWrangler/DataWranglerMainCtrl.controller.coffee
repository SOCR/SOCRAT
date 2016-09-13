'use strict'

require 'jquery-highlight'
require 'datatables.net'
require 'datatables.net-dt/css/jquery.datatables.css'
require 'data-wrangler/lib/hoverIntent/hoverIntent.js'
require 'data-wrangler/style/layout.css'
require 'data-wrangler/style/editor.css'
require 'data-wrangler/style/table.css'
require 'data-wrangler/style/wrangler.css'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class DataWranglerMainCtrl extends BaseCtrl
  @inject '$rootScope',
    'app_analysis_dataWrangler_wrangler'
    'app_analysis_dataWrangler_msgService'

  initialize: ->
    @wrangler = @app_analysis_dataWrangler_wrangler
    @msgManager = @app_analysis_dataWrangler_msgService
    @dw = require 'data-wrangler'

    # get initial settings
    @DATA_TYPES = @msgManager.getSupportedDataTypes()
    @dataType = ''

    data = @wrangler.init().then (status) =>
      if status
        @dataType = @DATA_TYPES.FLAT
        w = @dw.wrangle()

    # listen to state change and save data when exiting Wrangle Data
    stateListener = @$rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) =>
      if fromState.name? and fromState.name is 'app_analysis_dataWrangler'
        if @dataType is @DATA_TYPES.FLAT
        # save data to db on exit from wrangler
          @wrangler.saveData()
        # signal to show sidebar
        @msgManager.broadcast 'wrangler:done'
        # unsubscribe
        stateListener()
