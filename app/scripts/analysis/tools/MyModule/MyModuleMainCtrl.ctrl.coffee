'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleMainCtrl extends BaseCtrl
  @inject 'app_analysis_mymodule_dataService', '$scope'

  initialize: ->
    @dataService = @app_analysis_mymodule_dataService
    @title = 'Mymodule module'
    @$scope.$on 'MyModule:updateDataPoints', (event, data) =>
    	@data_from_db = data;