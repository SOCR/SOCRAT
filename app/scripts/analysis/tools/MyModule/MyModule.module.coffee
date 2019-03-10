'use strict'
# import module class
Module = require 'scripts/BaseClasses/BaseModule.coffee'
# export instance of new module
module.exports = myModule = new Module
  # module id for registration
  id: 'socrat_analysis_myModule'
  # module components
  components:
    services:
      'socrat_analysis_myModule_initService': require 'scripts/analysis/tools/MyModule/MyModuleInit.service.coffee'
      'socrat_analysis_myModule_msgService': require 'scripts/analysis/tools/MyModule/MyModuleMsgService.service.coffee'
      'socrat_analysis_myModule_dataService': require 'scripts/analysis/tools/MyModule/MyModuleDataService.service.coffee'
      'socrat_analysis_myModule_myService': require 'scripts/analysis/tools/MyModule/MyModuleMyService.service.coffee'
    controllers:
      'myModuleMainCtrl': require 'scripts/analysis/tools/MyModule/MyModuleMainCtrl.ctrl.coffee'
      'myModuleSidebarCtrl': require 'scripts/analysis/tools/MyModule/MyModuleSidebarCtrl.ctrl.coffee'
    directives:
      'socratmyModuleDir': require 'scripts/analysis/tools/MyModule/MyModuleDir.directive.coffee'
  # module state config
  state:
    # module name to show in UI
    name: 'Felix Module'
    url: '/tools/MyModule'
    mainTemplate: require 'partials/analysis/tools/MyModule/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/MyModule/sidebar.jade'