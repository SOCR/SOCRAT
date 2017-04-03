'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleSidebarCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService', 'socrat_analysis_mymodule_msgService'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @msgService = @socrat_analysis_mymodule_msgService

    # @standardization = @socrat_analysis_mymodule_standardization
    # @options =[@Standardization, @Whatever]

    @dataService.getData().then (obj) =>
      @msgService.broadcast 'mymodule:dataFromDb', obj
      console.log 'DATASET!!!!!!!!!!!!!!!!!!!!!!'
