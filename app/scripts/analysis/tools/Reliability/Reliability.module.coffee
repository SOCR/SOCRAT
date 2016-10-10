'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = reliability = new Module

  # module id for registration
  id: 'app_analysis_reliability'

  # module components
  components:
    services:
      'app_analysis_reliability_initService': require 'scripts/analysis/tools/Reliability/ReliabilityInit.service.coffee'
      'app_analysis_reliability_msgService': require 'scripts/analysis/tools/Reliability/ReliabilityMsgService.service.coffee'
      'app_analysis_reliability_dataService': require 'scripts/analysis/tools/Reliability/ReliabilityDataService.service.coffee'
      'app_analysis_reliability_tests': require 'scripts/analysis/tools/Reliability/ReliabilityTests.service.coffee'
    controllers:
      'reliabilityMainCtrl': require 'scripts/analysis/tools/Reliability/ReliabilityMainCtrl.ctrl.coffee'
      'reliabilitySidebarCtrl': require 'scripts/analysis/tools/Reliability/ReliabilitySidebarCtrl.ctrl.coffee'

  # module state config
  state:
    # module name to show in UI
    name: 'Reliability'
    url: '/tools/reliability'
    mainTemplate: require 'partials/analysis/tools/Reliability/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/Reliability/sidebar.jade'
