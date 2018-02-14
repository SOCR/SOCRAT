'use strict'
# import module class
Module = require 'scripts/BaseClasses/BaseModule.coffee'
# export instance of new module
module.exports = modeler = new Module
  # module id for registration
  id: 'app_analysis_modeler'
  # module components
  components:
    services:
      'app_analysis_modeler_initService': require 'scripts/analysis/tools/Modeler/ModelerInit.service.coffee'
      'app_analysis_modeler_msgService': require 'scripts/analysis/tools/Modeler/ModelerMsgService.service.coffee'
      #'app_analysis_modeler_myService': require 'scripts/analysis/tools/Modeler/ModelerMyService.service.coffee'
      'app_analysis_modeler_dataService': require 'scripts/analysis/tools/Modeler/ModelerDataService.service.coffee'
      'app_analysis_modeler_distrNormal': require 'scripts/analysis/tools/Modeler/ModelerDistributionNormal.service.coffee'
      'app_analysis_modeler_distrLaplace': require 'scripts/analysis/tools/Modeler/ModelerDistributionLaplace.service.coffee'
      'app_analysis_modeler_distrCauchy': require 'scripts/analysis/tools/Modeler/ModelerDistributionCauchy.service.coffee'
      'app_analysis_modeler_distrMaxwellBoltzman': require 'scripts/analysis/tools/Modeler/ModelerDistributionMaxwellBoltzman.service.coffee'
      'app_analysis_modeler_distrBinomial': require 'scripts/analysis/tools/Modeler/ModelerDistributionBinomial.service.coffee'
      'app_analysis_modeler_distrChiSquared': require 'scripts/analysis/tools/Modeler/ModelerDistributionChiSquared.service.coffee'
      'app_analysis_modeler_distrLogNormal': require 'scripts/analysis/tools/Modeler/ModelerDistributionLogNormal.service.coffee'
      'app_analysis_modeler_distrExponential': require 'scripts/analysis/tools/Modeler/ModelerDistributionExponential.service.coffee'
      'app_analysis_modeler_distrWeibull': require 'scripts/analysis/tools/Modeler/ModelerDistributionWeibull.service.coffee'

      'app_analysis_modeler_distList': require 'scripts/analysis/tools/Modeler/ModelerDistList.service.coffee'
      #'app_analysis_modeler_hist': require 'scripts/analysis/charts/ChartsHistogram.service.coffee'
      'app_analysis_modeler_hist': require 'scripts/analysis/tools/Modeler/ModelerHistPlot.service.coffee'
      'app_analysis_modeler_router': require 'scripts/analysis/tools/Modeler/ModelerRouter.service.coffee'

      'app_analysis_modeler_getParams': require 'scripts/analysis/tools/Modeler/ModelerGetParams.service.coffee'
      'app_analysis_modeler_kernelDensityPlotter': require 'scripts/analysis/tools/Modeler/ModelerKernelDensityPlot.service.coffee'

    controllers:
      'ModelerMainCtrl': require 'scripts/analysis/tools/Modeler/ModelerMainCtrl.ctrl.coffee'
      'ModelerSidebarCtrl': require 'scripts/analysis/tools/Modeler/ModelerSidebarCtrl.ctrl.coffee'

    directives:
      'modelerdir': require 'scripts/analysis/tools/Modeler/ModelerVizDir.directive.coffee'


  state:
      # module name to show in UI
    name: 'Modeler'
    url: '/tools/modeler'
    mainTemplate: require 'partials/analysis/tools/modeler/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/modeler/sidebar.jade'
