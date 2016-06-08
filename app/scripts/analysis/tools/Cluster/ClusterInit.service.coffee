'use strict'

ModuleInitService = require 'scripts/BaseClasses/ModuleInitService.coffee'

module.exports = class ClusterInitService extends ModuleInitService
  @inject 'app_analysis_cluster_msgService'
