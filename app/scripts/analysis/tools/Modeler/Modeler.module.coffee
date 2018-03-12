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
      'app_analysis_modeler_initService': require 'scripts/analysis/tools/Modeler/ModelerInitService.service.coffee'
      'app_analysis_modeler_msgService': require 'scripts/analysis/tools/Modeler/ModelerMsgService.service.coffee'
      'app_analysis_modeler_dataService': require 'scripts/analysis/tools/Modeler/ModelerDataService.service.coffee'
      'socrat_modeler_distribution_normal': require 'scripts/analysis/tools/Modeler/ModelerDistributionNormal.service.coffee'
      'socrat_modeler_distribution_laplace': require 'scripts/analysis/tools/Modeler/ModelerDistributionLaplace.service.coffee'
      'socrat_modeler_distribution_cauchy': require 'scripts/analysis/tools/Modeler/ModelerDistributionCauchy.service.coffee'
      'socrat_modeler_distribution_maxwell_boltzman': require 'scripts/analysis/tools/Modeler/ModelerDistributionMaxwellBoltzman.service.coffee'
      'socrat_modeler_distribution_binomial': require 'scripts/analysis/tools/Modeler/ModelerDistributionBinomial.service.coffee'
      'socrat_modeler_distribution_ChiSquared': require 'scripts/analysis/tools/Modeler/ModelerDistributionChiSquared.service.coffee'
      'socrat_modeler_distribution_LogNormal': require 'scripts/analysis/tools/Modeler/ModelerDistributionLogNormal.service.coffee'

      'socrat_modeler_distribution_exponential': require 'scripts/analysis/tools/Modeler/ModelerDistributionExponential.service.coffee'
      'socrat_modeler_distribution_Weibull': require 'scripts/analysis/tools/Modeler/ModelerDistributionWeibull.service.coffee'

      'app_analysis_modeler_dist_list': require 'scripts/analysis/tools/Modeler/ModelerDistList.service.coffee'
      #'app_analysis_modeler_hist': require 'scripts/analysis/charts/ChartsHistogram.service.coffee'
      'app_analysis_modeler_hist': require 'scripts/analysis/tools/Modeler/ModelerHistPlot.service.coffee'
      'app_analysis_modeler_router': require 'scripts/analysis/tools/Modeler/ModelerRouter.service.coffee'

      'app_analysis_modeler_getParams': require 'scripts/analysis/tools/Modeler/ModelerGetParams.service.coffee'
      'app_analysis_modeler_kernel_density_plotter': require 'scripts/analysis/tools/Modeler/ModelerKernelDensityPlot.service.coffee'





    controllers:
      'modelerMainCtrl': require 'scripts/analysis/tools/Modeler/ModelerMainCtrl.ctrl.coffee'
      'modelerSidebarCtrl': require 'scripts/analysis/tools/Modeler/ModelerSidebarCtrl.ctrl.coffee'

    directives:
      'modelerVizDir': require 'scripts/analysis/tools/Modeler/ModelerVizDir.directive.coffee'


  state:
      # module name to show in UI
    name: 'Modeler'
    url: '/tools/modeler'
    mainTemplate: require 'partials/analysis/tools/modeler/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/modeler/sidebar.jade'
