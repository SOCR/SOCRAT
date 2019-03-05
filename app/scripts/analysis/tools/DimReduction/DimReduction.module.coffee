'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = dimReduction = new Module

  # module id for registration
  id: 'app_analysis_dimReduction'

  # module components
  components:
    services:
      'app_analysis_dimReduction_initService': require 'scripts/analysis/tools/DimReduction/DimReductionInit.service.coffee'
      'app_analysis_dimReduction_msgService': require 'scripts/analysis/tools/DimReduction/DimReductionMsgService.service.coffee'
      'app_analysis_dimReduction_dataService': require 'scripts/analysis/tools/DimReduction/DimReductionDataService.service.coffee'
      'app_analysis_dimReduction_algorithms': require 'scripts/analysis/tools/DimReduction/DimReductionAlgorithms.service.coffee'
      'app_analysis_dimReduction_tSne': require 'scripts/analysis/tools/DimReduction/DimReductionTSne.service.coffee'

    controllers:
      'dimReductionMainCtrl': require 'scripts/analysis/tools/DimReduction/DimReductionMainCtrl.ctrl.coffee'
      'dimReductionSidebarCtrl': require 'scripts/analysis/tools/DimReduction/DimReductionSidebarCtrl.ctrl.coffee'

    directives:
      'socratDimReductionViz': require 'scripts/analysis/tools/DimReduction/DimReductionVizDir.directive.coffee'

  # module state config
  state:
    # module name to show in UI
    name: 'Dimensionality Reduction'
    url: '/tools/dimReduction'
    mainTemplate: require 'partials/analysis/tools/DimReduction/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/DimReduction/sidebar.jade'
