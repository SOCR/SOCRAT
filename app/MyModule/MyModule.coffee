'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = charts = new Module

# module id for registration
  id: 'my_module'

# module components
  components:
    services:
      'myModule_initService': require 'MyModule/MyModuleInit.coffee'
      'myModule_msgService': require 'MyModule/MyModuleMsgService.coffee'
      'myModuleMyService': require 'MyModule/MyService.coffee'

    controllers:
      'MyModuleSidebarCtrl': require 'MyModule/MyModuleSidebarCtrl.coffee'
      'MyModuleMainCtrl': require 'MyModule/MyModuleMainCtrl.coffee'

    # directives:
    #   'myModuleDirective': require 'MyModule/MyModuleDir.coffee'

# module state config
  state:
# module name to show in UI
    name: 'My Module'
    url: '/mymodule'
    mainTemplate: require 'MyModule/main.jade'
    sidebarTemplate: require 'MyModule/sidebar.jade'
