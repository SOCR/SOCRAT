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
<<<<<<< HEAD
      'app_analysis_datalib_wrapper': require 'scripts/analysis/Datalib/DatalibWrapper.service.coffee'
=======
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe

    runBlock: require 'scripts/analysis/Datalib/DatalibRunBlock.run.coffee'
