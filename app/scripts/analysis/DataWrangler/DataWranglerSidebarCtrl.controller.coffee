'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'


module.exports = class DataWranglerSidebarCtrl extends BaseCtrl
  @inject '$scope', 'app_analysis_dataWrangler_msgService'

  # toggle sidebar
  toggleSidebar: ->
    @$scope.$emit 'toggle sidebar'

  initialize: ->
    @eventManager = @app_analysis_dataWrangler_msgService
    console.log 'wrangleDataSidebarCtrl executed'

    # bring sidebar back on exit
    @$scope.$on 'wrangler:done', (event, results) =>
      @toggleSidebar()

    @toggleSidebar()

