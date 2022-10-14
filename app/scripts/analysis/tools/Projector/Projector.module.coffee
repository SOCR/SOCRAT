'use strict'
# import module class
Module = require 'scripts/BaseClasses/BaseModule.coffee'
# export instance of new module
module.exports = Projector = new Module
  # module id for registration
  id: 'app_analysis_projector'
  # module components
  components:
    services:
      'app_analysis_projector_initService': require 'scripts/analysis/tools/Projector/ProjectorInit.service.coffee'
      'app_analysis_projector_msgService': require 'scripts/analysis/tools/Projector/ProjectorMsgService.service.coffee'
      'app_analysis_projector_dataService': require 'scripts/analysis/tools/Projector/ProjectorDataService.service.coffee'
    
    controllers:
      'ProjectorMainCtrl': require 'scripts/analysis/tools/Projector/ProjectorMainCtrl.controller.coffee'
      'ProjectorSidebarCtrl': require 'scripts/analysis/tools/Projector/ProjectorSidebarCtrl.controller.coffee'


  state:
    name: 'Projector'
    url: '/Projector'
    mainTemplate: require 'partials/analysis/tools/Projector/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/Projector/sidebar.jade'