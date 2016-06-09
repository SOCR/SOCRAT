'use strict'

ModuleInitService = require 'scripts/BaseClasses/ModuleInitService.coffee'

module.exports = class GetDataInitService extends ModuleInitService
  @inject 'app_analysis_getData_msgService'

  initialize: ->
    @msgService = @app_analysis_getData_msgService
