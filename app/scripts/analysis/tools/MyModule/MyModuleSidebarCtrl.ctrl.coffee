'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleSidebarCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService',
    'socrat_analysis_mymodule_msgService'

  initialize: ->
    @dataService = @app_analysis_mymodule_dataService
    @msgService = @app_analysis_mymodule_msgService
