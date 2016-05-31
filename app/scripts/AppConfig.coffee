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
    clusterInitService = angular.module(ClusterModule::id)

    clusterModuleComponents = ClusterModule::components
    for serviceName, service of clusterModuleComponents.services
      console.log 'core: starting service: ' + serviceName
      clusterInitService.service serviceName, service

    console.log clusterInitService
    console.log 'CLUSTER CREATED'

  @initModules: ->
    console.log modules
#    for module in modules
#      if module.startsWith

