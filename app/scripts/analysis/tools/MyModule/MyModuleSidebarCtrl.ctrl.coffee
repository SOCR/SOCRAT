'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_mymodule_dataService', 'app_analysis_mymodule_msgService'


  initialize: ->
    @dataService = @app_analysis_mymodule_dataService
    @msgService = @app_analysis_mymodule_msgService
    @dataService.getData().then (obj) =>
        @msgService.broadcast 'MyModule:updateDataPoints', obj