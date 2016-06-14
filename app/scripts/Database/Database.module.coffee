'use strict'

Module = require 'scripts/BaseClasses/Module.coffee'

module.exports = db = new Module

# module id for registration
  id: 'app_analysis_database'

# module components
  components:
    services:
      'app_analysis_database_initService': require 'scripts/Database/DatabaseInit.service.coffee'
      'app_analysis_database_msgService': require 'scripts/Database/DatabaseMsgService.service.coffee'
      'app_analysis_database_dataAdaptor': require 'scripts/Database/DatabaseDataAdaptor.service.coffee'
      'app_analysis_database_nestedStorage': require 'scripts/Database/DatabaseNestedStorage.service.coffee'
      'app_analysis_database_dv': require 'scripts/Database/DatabaseDatavore.service.coffee'
      'app_analysis_database_handler': require 'scripts/Database/DatabaseHandler.service.coffee'
