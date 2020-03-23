'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = dimensionReduction = new Module

# module id for registration
  id: 'app_analysis_dimension_reduction'

  # module components
  components:
    services:
      'app_analysis_dimension_reduction_dataService': require 'scripts/analysis/tools/DimensionReduction/DimensionReductionDataService.service.coffee'
      'app_analysis_dimension_reduction_msgService': require 'scripts/analysis/tools/DimensionReduction/DimensionReductionMsgService.service.coffee'
      'app_analysis_dimension_reduction_dataSetConfig': require 'scripts/analysis/tools/DimensionReduction/DataSetConfig.service.coffee'

    controllers:
      'dimensionReductionSidebarCtrl': require 'scripts/analysis/tools/DimensionReduction/DimensionReductionSidebarCtrl.ctrl.coffee'
      'dimensionReductionMainCtrl': require 'scripts/analysis/tools/DimensionReduction/DimensionReductionMainCtrl.ctrl.coffee'

    directives:
      'dimensionReductionViz': require 'scripts/analysis/tools/DimensionReduction/DimensionReductionDir.directive.coffee'

# module state config
  state:
# module name to show in UI
    name: 'Embedding Projector'
    url: '/tools/dimred/embedproj'
    mainTemplate: require 'partials/analysis/tools/DimensionReduction/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/DimensionReduction/sidebar.jade'
    
