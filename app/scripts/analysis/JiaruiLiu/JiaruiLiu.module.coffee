'use strict'
# import module class
Module = require 'scripts/BaseClasses/BaseModule.coffee'
# export instance of new module
module.exports = JiaruiLiu = new Module
  # module id for registration
  id: 'socrat_analysis_JiaruiLiu'
  # module components
  components:
    services:
      'socrat_analysis_JiaruiLiu_initService': require 'scripts/analysis/JiaruiLiu/JiaruiLiuInit.service.coffee'
      'socrat_analysis_JiaruiLiu_msgService': require 'scripts/analysis/JiaruiLiu/JiaruiLiuMsgService.service.coffee'
      'socrat_analysis_JiaruiLiu_dataService': require 'scripts/analysis/JiaruiLiu/JiaruiLiuDataService.service.coffee'
      'socrat_analysis_JiaruiLiu_myService': require 'scripts/analysis/JiaruiLiu/JiaruiLiuMyService.service.coffee'
    controllers:
      'JiaruiLiuMainCtrl': require 'scripts/analysis/JiaruiLiu/JiaruiLiuMainCtrl.controller.coffee'
      'JiaruiLiuSidebarCtrl': require 'scripts/analysis/JiaruiLiu/JiaruiLiuSidebarCtrl.controller.coffee'
    #directives:
      #'socratMyModuleDir': require 'scripts/analysis/MyModule/MyModuleDir.directive.coffee'
  # module state config
  state:
    # module name to show in UI
    name: 'Jiarui Liu'
    url: '/tools/JiaruiLiu'
    mainTemplate: require 'partials/analysis/JiaruiLiu/main.jade'
    sidebarTemplate: require 'partials/analysis/JiaruiLiu/sidebar.jade' 