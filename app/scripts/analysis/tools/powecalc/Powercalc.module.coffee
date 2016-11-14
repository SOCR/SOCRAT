'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = powercalc = new Module

  # module id for registration
  id: 'app_analysis_powercalc'

  # module components
  components:
    #services:
      #'app_analysis_cluster_initService': require 'scripts/analysis/tools/Cluster/ClusterInit.service.coffee'
      #'app_analysis_cluster_msgService': require 'scripts/analysis/tools/Cluster/ClusterMsgService.service.coffee'
      #'app_analysis_cluster_dataService': require 'scripts/analysis/tools/Cluster/ClusterDataService.service.coffee'
      #'app_analysis_cluster_algorithms': require 'scripts/analysis/tools/Cluster/ClusterAlgorithms.service.coffee'
      #'app_analysis_cluster_metrics': require 'scripts/analysis/tools/Cluster/ClusterMetrics.service.coffee'
      #'app_analysis_cluster_kMeans': require 'scripts/analysis/tools/Cluster/ClusterKMeans.service.coffee'
      #'app_analysis_cluster_spectral': require 'scripts/analysis/tools/Cluster/ClusterSpectral.service.coffee'

    #controllers:
      #'powercalcMainCtrl': require 'scripts/analysis/tools/Cluster/ClusterMainCtrl.ctrl.coffee'
      #'clusterSidebarCtrl': require 'scripts/analysis/tools/Cluster/ClusterSidebarCtrl.ctrl.coffee'

    #directives:
      #'socratClusterViz': require 'scripts/analysis/tools/Cluster/ClusterVizDir.directive.coffee'

  # module state config
  state:
    # module name to show in UI
    name: 'powercalc'
    url: '/tools/powercalc'
    mainTemplate: require 'partials/analysis/tools/powercalc/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/powercalc/sidebar.jade'
