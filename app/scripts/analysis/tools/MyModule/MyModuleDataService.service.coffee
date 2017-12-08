'use strict'
# import base class for data service
BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'
# export custom data service class
<<<<<<< HEAD
module.exports = class app_analysis_mymodule_dataService extends BaseModuleDataService
=======
module.exports = class MyModuleDataService extends BaseModuleDataService
>>>>>>> master
  # requires injection of $q and message service
  @inject '$q', 'app_analysis_mymodule_msgService'
  # requires renaming message service injection to @msgService
  initialize: () ->
<<<<<<< HEAD
    @msgManager = @app_analysis_mymodule_msgService
=======
    @msgManager = @app_analysis_MyModule_msgService
>>>>>>> master
    # indication of default messages for requesting and receiving data from SOCRAT
    @getDataRequest = @msgManager.getMsgList().outgoing[0]
    @getDataResponse = @msgManager.getMsgList().incoming[0]
