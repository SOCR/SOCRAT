'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = powercalc = new Module

  # module id for registration
  id: 'app_analysis_powercalc'

  # module components
  components:
    services:
      'app_analysis_powercalc_cfap': require 'powercalc'
      'app_analysis_powercalc_msgService': require 'PowercalcMsgService.service.coffee'
      'app_analysis_powercalc_dataService': require 'app_analysis_powercalc_dataService'

    controllers:
      #'powercalcMainCtrl': require 'scripts/analysis/tools/powercalc/PowercalcMainCtrl.ctrl.coffee'
      'clusterCtrl': require 'scripts/analysis/tools/powercalc/PowercalcCtrl.ctrl.coffee'

    #directives:
      #'socratClusterViz': require 'scripts/analysis/tools/Cluster/ClusterVizDir.directive.coffee'

  # module state config
  state:
    # module name to show in UI
    name: 'powercalc'
    url: '/tools/powercalc'
    mainTemplate: require 'partials/analysis/tools/powercalc/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/powercalc/sidebar.jade'
