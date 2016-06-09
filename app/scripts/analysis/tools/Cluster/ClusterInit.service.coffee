'use strict'

ModuleInitService = require 'scripts/BaseClasses/ModuleInitService.coffee'

module.exports = class ClusterInitService extends ModuleInitService
  @inject 'app_analysis_cluster_msgService'

  initialize: ->
    @msgService = @app_analysis_getData_msgService
