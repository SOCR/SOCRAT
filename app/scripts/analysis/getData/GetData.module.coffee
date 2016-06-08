'use strict'

Module = require 'scripts/Module/Module.coffee'

module.exports = getData = new Module

  # module id for registration
  id: 'app_analysis_getData'

  # module components
  components:
    services:
      'app_analysis_getData_initService': require 'scripts/analysis/getData/GetDataInit.service.coffee'
      'app_analysis_getData_msgService': require 'scripts/analysis/getData/GetDataMsgService.service.coffee'

    factories: []
    controllers: []
    directives: []

  # module state config
  state:
    # module name to show in UI
    name: 'Data Input'
    url: '/getData'
    mainTemplate: require 'partials/analysis/getData/main.jade'
    sidebarTemplate: require 'partials/analysis/getData/main.jade'

angular.module cluster.id, []
console.log 'Registered module: ' + cluster.id
