'use strict'

AppRoute = require 'scripts/AppRoute.coffee'

###
# @name AppConfig
# @desc Class for config block of application module
###
module.exports = class AppConfig extends AppRoute
  @setModuleList: (moduleList) ->
    modules = moduleList


    # TODO: clean up experiment code!
    ClusterModule = require 'scripts/analysis/tools/Cluster/Cluster.module.coffee'
    ClusterMsgService = require 'scripts/analysis/tools/Cluster/ClusterMsgService.service.coffee'
    clusterMsgService = angular.module(ClusterModule::id).service ClusterModule::id + '_msgService', ClusterMsgService
    console.log clusterMsgService
    console.log 'CLUSTER CREATED'

  @initModules: ->
    console.log modules
#    for module in modules
#      if module.startsWith

