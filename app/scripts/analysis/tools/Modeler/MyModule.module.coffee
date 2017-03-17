'use strict'
# import module class
Module = require 'scripts/BaseClasses/BaseModule.coffee'
# export instance of new module
module.exports = modeler = new Module
  # module id for registration
  id: 'socrat_analysis_mymodule'
  # module components
  components:
    services:
      'socrat_analysis_mymodule_initService': require 'scripts/analysis/tools/Modeler/MyModuleInit.service.coffee'
      'socrat_analysis_mymodule_msgService': require 'scripts/analysis/tools/Modeler/MyModuleMsgService.service.coffee'
      'socrat_analysis_mymodule_myService': require 'scripts/analysis/tools/Modeler/MyModuleMyService.service.coffee'
      'socrat_analysis_mymodule_dataService': require 'scripts/analysis/tools/Modeler/ModelerDataService.service.coffee'
      'socrat_modeler_distribution_normal': require 'scripts/analysis/tools/Modeler/ModelerDistributionNormal.service.coffee'
      'socrat_analysis_modeler_dist_list': require 'scripts/analysis/tools/Modeler/ModelerDistList.service.coffee'
      'socrat_analysis_modeler_hist': require 'scripts/analysis/charts/ChartsHistogram.service.coffee'
      'socrat_analysis_modeler_getParams': require 'scripts/analysis/tools/Modeler/ModelerGetParams.service.coffee'



    controllers:
      'ModelerMainCtrl': require 'scripts/analysis/tools/Modeler/ModelerMainCtrl.ctrl.coffee'
      'ModelerSidebarCtrl': require 'scripts/analysis/tools/Modeler/ModelerSidebarCtrl.ctrl.coffee'

    directives:
      'modelerdir': require 'scripts/analysis/tools/Modeler/ModelerDir.directive.coffee'


  state:
      # module name to show in UI
    name: 'Modeler'
    url: '/tools/modeler'
    mainTemplate: require 'partials/analysis/tools/modeler/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/modeler/sidebar.jade'


