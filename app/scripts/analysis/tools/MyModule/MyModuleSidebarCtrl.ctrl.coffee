'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleSidebarCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService',
    'socrat_analysis_mymodule_msgService'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @msgService = @socrat_analysis_mymodule_msgService

    # set up data controls
    @ready = off

    # dataset-specific
    @dataFrame = null

    @dataService.getData().then (obj) =>
      if obj.dataFrame
        @msgService.broadcast 'mymodule:displayData', obj.dataFrame
        # make local copy of data
        @dataFrame = obj.dataFrame
      else
        # TODO: add processing for nested object
        console.log 'NESTED DATASET'