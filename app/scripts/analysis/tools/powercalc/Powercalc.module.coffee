'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = powercalc = new Module

  # module id for registration
  id: 'app_analysis_powercalc'

  # module components
  components:
    services:
      'app_analysis_powercalc_msgService': require 'scripts/analysis/tools/powercalc/PowercalcMsgService.service.coffee'
      'app_analysis_powercalc_algorithms': require 'scripts/analysis/tools/powercalc/PowercalcAlgorithms.service.coffee'
      'app_analysis_powercalc_initService': require 'scripts/analysis/tools/powercalc/PowercalcInit.service.coffee'
      'app_analysis_powercalc_dataService': require 'scripts/analysis/tools/powercalc/PowercalcDataService.service.coffee'
      'app_analysis_powercalc_twoTest': require 'scripts/analysis/tools/powercalc/PowercalcTwoTGUI.service.coffee'
      'app_analysis_powercalc_oneTest': require 'scripts/analysis/tools/powercalc/PowercalcOneTGUI.service.coffee'

    controllers:
      'powercalcMainCtrl': require 'scripts/analysis/tools/powercalc/PowercalcMainCtrl.ctrl.coffee'
      'powercalcSidebarCtrl': require 'scripts/analysis/tools/powercalc/PowercalcSidebarCtrl.ctrl.coffee'

    #directives:
      #'socratClusterViz': require 'scripts/analysis/tools/Cluster/ClusterVizDir.directive.coffee'

  # module state config
  state:
    # module name to show in UI
    name: 'Power Analysis'
    url: '/tools/powercalc'
    mainTemplate: require 'partials/analysis/tools/powercalc/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/powercalc/sidebar.jade'
