'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = getData = new Module

  # module id for registration
  id: 'app_analysis_getData'

  # module components
  components:
    services:
      'app_analysis_getData_initService': require 'scripts/analysis/GetData/GetDataInit.service.coffee'
      'app_analysis_getData_msgService': require 'scripts/analysis/GetData/GetDataMsgService.service.coffee'
      'app_analysis_getData_dataAdaptor': require 'scripts/analysis/GetData/GetDataDataAdaptor.service.coffee'
      'app_analysis_getData_inputCache': require 'scripts/analysis/GetData/GetDataInputCache.service.coffee'
      'app_analysis_getData_showState': require 'scripts/analysis/GetData/GetDataShowState.service.coffee'
      'app_analysis_getData_dataService': require 'scripts/analysis/GetData/GetDataDataService.service.coffee'
      'app_analysis_getData_socrDataConfig': require 'scripts/analysis/GetData/GetDataSocrDataConfig.service.coffee'
    controllers:
      'GetDataSidebarCtrl': require 'scripts/analysis/GetData/GetDataSidebarCtrl.controller.coffee'
      'GetDataMainCtrl': require 'scripts/analysis/GetData/GetDataMainCtrl.controller.coffee'
    directives:
      'getdatadragndrop': require 'scripts/analysis/GetData/GetDataDragNDropDir.directive.coffee'
      'colhistogram' : require 'scripts/analysis/GetData/GetDataHistogramDir.directive.coffee'

  # module state config
  state:
    # module name to show in UI
    name: 'Data Input'
    url: '/getData'
    mainTemplate: require 'partials/analysis/getData/main.jade'
    sidebarTemplate: require 'partials/analysis/getData/sidebar.jade'

  # 3rd-party dependencies
  deps: ['ngHandsontable']
