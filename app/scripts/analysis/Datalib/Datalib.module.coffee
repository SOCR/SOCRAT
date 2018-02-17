'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = db = new Module

# module id for registration
  id: 'app_analysis_datalib'

# module components
  components:
    services:
      'app_analysis_datalib_initService': require 'scripts/analysis/Datalib/DatalibInit.service.coffee'
      'app_analysis_datalib_msgService': require 'scripts/analysis/Datalib/DatalibMsgService.service.coffee'
      'app_analysis_datalib_dataAdaptor': require 'scripts/analysis/Datalib/DatalibDataAdaptor.service.coffee'
      'app_analysis_datalib_api': require 'scripts/analysis/Datalib/DatalibApi.service.coffee'

    runBlock: require 'scripts/analysis/Datalib/DatalibRunBlock.run.coffee'
