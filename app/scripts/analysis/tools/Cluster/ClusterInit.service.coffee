'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class ClusterInitService extends BaseModuleInitService
  @inject 'app_analysis_cluster_msgService'

  initialize: ->
    @msgService = @app_analysis_cluster_msgService
    @setMsgList()
