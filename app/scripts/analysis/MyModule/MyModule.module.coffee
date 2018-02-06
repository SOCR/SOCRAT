'use strict'
# import module class
Module = require 'scripts/BaseClasses/BaseModule.coffee'
# export instance of new module
module.exports = myModule = new Module
  # module id for registration
  id: 'socrat_analysis_mymodule'
  # module components
  components:
    services:
      'socrat_analysis_mymodule_initService': require 'scripts/analysis/MyModule/MyModuleInit.service.coffee'
      'socrat_analysis_mymodule_msgService': require 'scripts/analysis/MyModule/MyModuleMsgService.service.coffee'
      'socrat_analysis_mymodule_myService': require 'scripts/analysis/MyModule/MyModuleMyService.service.coffee'
    controllers:
      'mymoduleMainCtrl': require 'scripts/analysis/tools/MyModule/MyModuleMainCtrl.ctrl.coffee'
      'mymoduleSidebarCtrl': require 'scripts/analysis/tools/MyModule/MyModuleSidebarCtrl.ctrl.coffee'
    directives:
      'socratMyModuleDir': require 'scripts/analysis/tools/MyModule/MyModuleDir.directive.coffee'
  # module state config
  state:
    # module name to show in UI
    name: 'My Awesome Module'
    url: '/tools/mymodule'
    mainTemplate: require 'partials/analysis/tools/MyModule/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/MyModule/sidebar.jade'