'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ClusterDataService extends BaseModuleDataService
  @inject '$q', 'app_analysis_cluster_msgService'
