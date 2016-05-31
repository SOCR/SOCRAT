'use strict'

Module = require 'scripts/Module/Module.coffee'

module.exports = cluster = new Module

  # module id for registration
  id: 'app_analysis_cluster'

  # module components
  components:
    services:
      'app_analysis_cluster_initService': require 'scripts/analysis/tools/Cluster/ClusterInit.service.coffee'
      'app_analysis_cluster_msgService': require 'scripts/analysis/tools/Cluster/ClusterMsgService.service.coffee'

    factories: []
    controllers: []
    directives: []

  # module state config
  state:
    id: 'cluster'
    url: '/tools/cluster'
    mainTemplate: 'partials/analysis/tools/cluster/main.jade'
    sidebarTemplate: 'partials/analysis/tools/cluster/sidebar.jade'

angular.module cluster.id, []
console.log 'Registered module: ' + cluster.id
