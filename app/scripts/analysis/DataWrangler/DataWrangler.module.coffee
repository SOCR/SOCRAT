'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = dataWrangler = new Module

# module id for registration
  id: 'app_analysis_dataWrangler'

# module components
  components:
    services:
      'app_analysis_dataWrangler_initService': require 'scripts/analysis/DataWrangler/DataWranglerInit.service.coffee'
      'app_analysis_dataWrangler_msgService': require 'scripts/analysis/DataWrangler/DataWranglerMsgService.service.coffee'
      'app_analysis_dataWrangler_dataAdaptor': require 'scripts/analysis/DataWrangler/DataWranglerDataAdaptor.service.coffee'
      'app_analysis_dataWrangler_dataService': require 'scripts/analysis/DataWrangler/DataWranglerDataService.service.coffee'
      'app_analysis_dataWrangler_wrangler': require 'scripts/analysis/DataWrangler/DataWranglerWrangler.service.coffee'
    controllers:
      'DataWranglerSidebarCtrl': require 'scripts/analysis/DataWrangler/DataWranglerSidebarCtrl.controller.coffee'
      'DataWranglerMainCtrl': require 'scripts/analysis/DataWrangler/DataWranglerMainCtrl.controller.coffee'
    directives:
      'wranglerdir': require 'scripts/analysis/DataWrangler/DataWranglerWranglerDir.directive.coffee'

  # module state config
  state:
  # module name to show in UI
    name: 'Wrangle Data'
    url: '/dataWrangler'
    mainTemplate: require 'partials/analysis/DataWrangler/main.jade'
    sidebarTemplate: require 'partials/analysis/DataWrangler/sidebar.jade'
