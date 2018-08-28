'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = dimensionReduction = new Module

# module id for registration
  id: 'app_analysis_dimension_reduction'

# module state config
  state:
# module name to show in UI
    name: 'Dimension Reduction'
    url: '/tools/DimensionReduction'
    mainTemplate: require 'partials/analysis/tools/DimensionReduction/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/DimensionReduction/sidebar.jade'
