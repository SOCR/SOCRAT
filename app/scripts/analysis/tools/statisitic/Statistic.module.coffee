'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = statistic = new Module

  # module id for registration
  id: 'app_analysis_statistic'

  # module components
  components:
    services:
      'app_analysis_statistic_msgService': require 'scripts/analysis/tools/statistic/StatisticMsgService.service.coffee'
      'app_analysis_statistic_algorithms': require 'scripts/analysis/tools/statistic/StatisticAlgorithms.service.coffee'
      'app_analysis_statistic_initService': require 'scripts/analysis/tools/statistic/StatisticInit.service.coffee'
      'app_analysis_statistic_dataService': require 'scripts/analysis/tools/statistic/StatisticDataService.service.coffee'

    controllers:
      'statisticMainCtrl': require 'scripts/analysis/tools/statistic/StatisticMainCtrl.ctrl.coffee'
      'statisticSidebarCtrl': require 'scripts/analysis/tools/statistic/StatisticSidebarCtrl.ctrl.coffee'

    #directives:
      #'socratClusterViz': require 'scripts/analysis/tools/Cluster/ClusterVizDir.directive.coffee'

  # module state config
  state:
    # module name to show in UI
    name: 'Power Analysis'
    url: '/tools/statistic'
    mainTemplate: require 'partials/analysis/tools/statistic/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/statistic/sidebar.jade'
