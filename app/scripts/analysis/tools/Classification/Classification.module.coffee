'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = cluster = new Module

  # module id for registration
  id: 'app_analysis_classification'

  # module components
  components:
    services:
      'app_analysis_classification_initService': require 'scripts/analysis/tools/Classification/ClassificationInit.service.coffee'
      'app_analysis_classification_msgService': require 'scripts/analysis/tools/Classification/ClassificationMsgService.service.coffee'
      'app_analysis_classification_dataService': require 'scripts/analysis/tools/Classification/ClassificationDataService.service.coffee'
      'app_analysis_classification_algorithms': require 'scripts/analysis/tools/Classification/ClassificationAlgorithms.service.coffee'
      'app_analysis_classification_metrics': require 'scripts/analysis/tools/Classification/ClassificationMetrics.service.coffee'
      'app_analysis_classification_csvc': require 'scripts/analysis/tools/Classification/ClassificationCSVC.service.coffee'
      'app_analysis_classification_classificationgraph': require 'scripts/analysis/tools/Classification/ClassificationGraphService.service.coffee'
      'app_analysis_classification_knn': require 'scripts/analysis/tools/Classification/ClassificationKNN.service.coffee'

    controllers:
      'classificationMainCtrl': require 'scripts/analysis/tools/Classification/ClassificationMainCtrl.ctrl.coffee'
      'classificationSidebarCtrl': require 'scripts/analysis/tools/Classification/ClassificationSidebarCtrl.ctrl.coffee'

    directives:
      'classificationgraph': require 'scripts/analysis/tools/Classification/ClassificationDir.directive.coffee'

  # module state config
  state:
    # module name to show in UI
    name: 'Classification'
    url: '/tools/classification'
    mainTemplate: require 'partials/analysis/tools/classification/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/classification/sidebar.jade'
