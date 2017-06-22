'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class PowercalcAlgorithms extends BaseModuleDataService
  @inject 'app_analysis_powercalc_msgService'

  initialize: ->
    @msgManager = @app_analysis_powercalc_msgService


  ############
