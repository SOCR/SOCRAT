'use strict'

ModuleInitService = require 'scripts/BaseClasses/ModuleInitService.coffee'

module.exports = class DatabaseInitService extends ModuleInitService
  @inject 'app_analysis_database_msgService'

  initialize: ->
    @msgService = @app_analysis_db_msgService
