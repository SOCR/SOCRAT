'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ModelerSidebarCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService',
    'socrat_analysis_mymodule_msgService',
    '$scope',
    '$timeout'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @msgService = @socrat_analysis_mymodule_msgService
    @algorithms = ['Normal', 'Binomial', 'Poisson']
    @






