'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class SVMSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_svm_dataService',
    'app_analysis_svm_msgService'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @app_analysis_svm_dataService
    @msgService = @app_analysis_svm_msgService

    # set up data controls
    @ready = off

    # dataset-specific
    @dataFrame = null

    @dataService.getData().then (obj) =>
      if obj.dataFrame
        @msgService.broadcast 'svm:displayData', obj.dataFrame
        # make local copy of data
        @dataFrame = obj.dataFrame
      else
        # TODO: add processing for nested object
        console.log 'NESTED DATASET'