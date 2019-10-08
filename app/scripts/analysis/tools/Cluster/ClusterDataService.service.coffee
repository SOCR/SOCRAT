'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ClusterDataService extends BaseModuleDataService
  @inject '$q', 'app_analysis_cluster_msgService'

  # requires renaming message service injection to @msgService
  initialize: () ->
    @msgManager = @app_analysis_cluster_msgService
    check_1 = @msgManager.getMsgList()
    console.log check_1
    @getDataRequest = check_1.outgoing[0]
    check_2 = @msgManager.getMsgList()
    console.log check_2
    @getDataResponse = check_2.incoming[0]

  inferDataTypes: (data, cb) ->
    @post(@msgManager.getMsgList().outgoing[1], @msgManager.getMsgList().incoming[1], data).then (resp) =>
      cb resp
