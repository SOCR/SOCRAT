'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleMainCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
