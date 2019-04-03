'use strict'
# import base class for data service
BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'
# export custom data service class
module.exports = class MyModuleDataService extends BaseModuleDataService
  # requires injection of $q and message service
  @inject '$q', 'socrat_analysis_mymodule_msgService'
  # requires renaming message service injection to @msgService
  initialize: () ->
    @msgManager = @socrat_analysis_cluster_msgService
    # indication of default messages for requesting and receiving data from SOCRAT
    @getDataRequest = @msgManager.getMsgList().outgoing[0]
    @getDataResponse = @msgManager.getMsgList().incoming[0]
