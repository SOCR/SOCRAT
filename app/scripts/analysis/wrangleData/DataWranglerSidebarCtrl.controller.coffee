'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'


module.exports = class DataWranglerSidebarCtrl extends BaseCtrl
  @inject '$scope', 'app_analysis_dataWrangler_msgService'

  initialize: ->
    @eventManager = @app_analysis_dataWrangler_msgService
    console.log 'wrangleDataSidebarCtrl executed'

    # hide sidebar
    @$scope.$parent.toggle()
    # bring sidebar back on exit
    @$scope.$on 'wrangler:done', (event, results) ->
      @$scope.$parent.toggle()
