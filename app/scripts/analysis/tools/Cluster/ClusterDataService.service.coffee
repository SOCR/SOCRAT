'use strict'

ModuleDataService = require 'scripts/BaseClasses/ModuleDataService.coffee'

module.exports = class ClusterDataService extends ModuleDataService
  @inject '$q', 'app_analysis_cluster_msgService'
