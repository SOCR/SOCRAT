'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class DatabaseInitService extends BaseModuleInitService
  @inject 'app_analysis_database_msgService'

  initialize: ->
    @msgService = @app_analysis_db_msgService
