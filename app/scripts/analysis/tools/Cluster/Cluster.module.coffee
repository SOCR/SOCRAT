'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = cluster = new Module

  # module id for registration
  id: 'app_analysis_cluster'

  # module components
  components:
    services:
      'app_analysis_cluster_initService': require 'scripts/analysis/tools/Cluster/ClusterInit.service.coffee'
      'app_analysis_cluster_msgService': require 'scripts/analysis/tools/Cluster/ClusterMsgService.service.coffee'
      'app_analysis_cluster_dataService': require 'scripts/analysis/tools/Cluster/ClusterDataService.service.coffee'
      'app_analysis_cluster_algorithms': require 'scripts/analysis/tools/Cluster/ClusterAlgorithms.service.coffee'

    controllers:
      'clusterMainCtrl': require 'scripts/analysis/tools/Cluster/ClusterMainCtrl.ctrl.coffee'
      'clusterSidebarCtrl': require 'scripts/analysis/tools/Cluster/ClusterSidebarCtrl.ctrl.coffee'

    directives:
      'socratClusterViz': require 'scripts/analysis/tools/Cluster/ClusterVizDir.directive.coffee'

  # module state config
  state:
    # module name to show in UI
    name: 'Clustering'
    url: '/tools/cluster'
    mainTemplate: require 'partials/analysis/tools/cluster/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/cluster/sidebar.jade'
