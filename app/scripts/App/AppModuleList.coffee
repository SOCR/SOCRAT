'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

###
# @name AppModuleList
# @desc Class for listing of all modules that exist in the app by category
###
module.exports = class AppModuleList

  system: [
    'ui.router'
    'ui.router.compat'
    'ui.bootstrap'
    'ngCookies'
    'ngResource'
    'ngSanitize'
    'app_controllers'
    'app_directives'
    'app_filters'
    'app_services'
    'app_core'
    'app_mediator'
    'frapontillo.bootstrap-switch'
  ]

  # include custom modules
  # single module are included as entries into main menu
  # if they have state in their module config file
  # named lists are included as drop-downs into main menu
  analysis: [
    require 'scripts/Database/Database.module.coffee'
  ,
    require 'scripts/analysis/Datalib/Datalib.module.coffee'
  ,
    require 'scripts/analysis/GetData/GetData.module.coffee'
  ,
    require 'scripts/analysis/DataWrangler/DataWrangler.module.coffee'
  ,
    require 'scripts/analysis/charts/Charts.module.coffee'
  ,
    Tools: [
      require 'scripts/analysis/tools/Cluster/Cluster.module.coffee'
    ,
      require 'scripts/analysis/tools/Reliability/Reliability.module.coffee'
    ,
      require 'scripts/analysis/tools/Modeler/MyModule.module.coffee'
    ]
  ]

  ##### access methods #####

  getAll: ->
    system: @system
    analysis: @analysis
    tools: @tools

  getAnalysisModules: ->
    @analysis

  listAnalysisModules: ->
    modules = []
    for m in @analysis
      m = if m instanceof Module then [m.id] else (v.map((e) -> e.id) for k, v of m)[0]
      modules = modules.concat m
    modules

  listAll: ->
    console.log @system
    @system.concat @listAnalysisModules()
