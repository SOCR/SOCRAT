'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ModelerMainCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @DATA_TYPES = @dataService.getDataTypes()
