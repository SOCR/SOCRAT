'use strict'

###
# @name AppModuleList
# @desc Class for listing of all modules that exist in the app by category
###
module.exports = class AppModuleList

  getAll: -> (moduleList for k, moduleList of @constructor.modules).reduce (t, s) -> t.concat s
  getSystem: -> @constructor.modules.system
  getAnalysis: -> @constructor.modules.analysis
  getTools: -> @constructor.modules.tools
  getAnalysisTools: -> @getAnalysis().concat @getTools()

  @modules:
    system: [
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
#      'app_database'
    ]
    analysis: [
#      'app_analysis_getData'
#      'app_analysis_wrangleData'
#      'app_analysis_instrPerfEval'
#      'app_analysis_charts'
    ]
    tools: [
      'app_analysis_cluster'
    ]
