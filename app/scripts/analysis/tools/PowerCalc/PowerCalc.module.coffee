'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = powerCalc = new Module

  # module id for registration
  id: 'app_analysis_powercalc'

  # module components
  components:
    services:
      'app_analysis_powerCalc_msgService': require 'scripts/analysis/tools/PowerCalc/PowerCalcMsgService.service.coffee'
      'app_analysis_powerCalc_algorithms': require 'scripts/analysis/tools/PowerCalc/PowerCalcAlgorithms.service.coffee'
      'app_analysis_powerCalc_initService': require 'scripts/analysis/tools/PowerCalc/PowerCalcInit.service.coffee'
      'app_analysis_powerCalc_dataService': require 'scripts/analysis/tools/PowerCalc/PowerCalcDataService.service.coffee'
      'app_analysis_powerCalc_twoTest': require 'scripts/analysis/tools/PowerCalc/PowerCalcTwoTGUI.service.coffee'
      'app_analysis_powerCalc_oneTest': require 'scripts/analysis/tools/PowerCalc/PowerCalcOneTGUI.service.coffee'

    controllers:
      'powerCalcMainCtrl': require 'scripts/analysis/tools/PowerCalc/PowerCalcMainCtrl.ctrl.coffee'
      'powerCalcSidebarCtrl': require 'scripts/analysis/tools/PowerCalc/PowerCalcSidebarCtrl.ctrl.coffee'

    directives:
      'powerCalcViz': require 'scripts/analysis/tools/PowerCalc/PowerCalcVizDir.directive.coffee'

  # module state config
  state:
    # module name to show in UI
    name: 'Power Analysis'
    url: '/tools/powercalc'
    mainTemplate: require 'partials/analysis/tools/PowerCalc/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/PowerCalc/sidebar.jade'
