'use strict'

#require 'scripts/analysis/tools/Cluster/Cluster.module.coffee'

module.exports = class AppModuleList
  modules: [
    'ui.router'
    'ui.router.compat'
    'ngCookies'
    'ngResource'
    'ngSanitize'
    'app_controllers'
    'app_directives'
    'app_filters'
    'app_services'
    'app_core'
    'app_mediator'
#  'app_database'
#  #charts module
##  'app_analysis_charts'
#  # Analysis modules
#  'app_analysis_getData'
##  'app_analysis_wrangleData'
##  'app_analysis_instrPerfEval'
    'app_analysis_cluster'
  ]
