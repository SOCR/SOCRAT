'use strict'

###
# @name AppModuleList
# @desc Class for listing of all modules that exist in the app by category
###
module.exports = class AppModuleList

#  getAll: -> (moduleList for k, moduleList of @constructor.modules).reduce (t, s) -> t.concat s
  getSystemList: -> @constructor.system
  getAnalysisModules: -> @constructor.analysis
  getToolModules: -> @constructor.tools
  getAnalysisAndToolModules: ->
    analysis: @getAnalysisModules()
    tools: @getToolModules()
  # Returns complete list of all modules
  getList: -> @getSystemList().concat(@getAnalysisModules().map((m) -> m.id), @getToolModules().map((m) -> m.id))

  @system: [
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

  ]

  @db: []#      'app_database'

  @analysis: []
#      'app_analysis_getData'
#      'app_analysis_wrangleData'
#      'app_analysis_instrPerfEval'
#      'app_analysis_charts'

  @tools:
      require 'scripts/analysis/tools/Cluster/Cluster.module.coffee'
#      'app_analysis_cluster': require 'scripts/analysis/tools/Cluster/Cluster.module.coffee'
