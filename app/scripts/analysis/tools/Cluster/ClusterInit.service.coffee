'use strict'

ModuleInitService = require 'scripts/Module/ModuleInitService.coffee'

module.exports = class ClusterInitService extends ModuleInitService

ClusterInitService.$inject = ['app_analysis_cluster_msgService']
