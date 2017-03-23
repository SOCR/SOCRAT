'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleMainCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService', '$scope'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService

    @title = 'My Awesome Module'

    @$scope.$on 'mymodule:dataFromDb', (event, data) =>
      @data_from_db = data
