'use strict'

Module = require 'scripts/BaseClasses/Module.coffee'
AppRoute = require 'scripts/App/AppRoute.coffee'
AppRun = require 'scripts/App/AppRun.coffee'

###
# @name AppConfig
# @desc Class for config block of application module
###
module.exports = class AppConfig

  # suffix to detect initialization service
  INIT_SERVICE_SUFFIX: '_initService'
  # list of custom modules and their services that need to be initialized
  runModules: []
  runServices: []

  constructor: (@moduleList) ->
    # create angular modules
    @addModuleComponents()

  addModuleComponents: (modules = @moduleList.getAnalysisModules()) ->
    # create modules components
    for module in modules
      # check if single module or group
      if module instanceof Module

        angModule = angular.module module.id

        moduleComponents = module.components
        # adding services
        for serviceName, Service of moduleComponents.services
          Service.register serviceName, angModule
          service = new Service()
          console.log 'AppConfig: created service ' + serviceName
          if serviceName.endsWith @INIT_SERVICE_SUFFIX
            @runModules.push module.id
            @runServices.push serviceName

        console.log 'AppConfig: created module ' + module.id

      # if collection of modules, recursively create
      else @addModuleComponents (v for k, v of module)[0]

  getConfigBlock: ->
    # create new router
    appRoute = new AppRoute @moduleList.listAnalysisModules()
    # workaround for dependency injection
    config = ($locationProvider, $urlRouterProvider, $stateProvider) =>
      appRoute.getRouter $locationProvider, $urlRouterProvider, $stateProvider
    # dependencies for AppRoute
    config.$inject = ['$locationProvider', '$urlRouterProvider', '$stateProvider']
    config

  getRunBlock: ->
    # create new run block
    appRun = new AppRun @moduleList.getAnalysisModules(), @runModules
    # pass the context and module init services
    runBlock = ($rootScope, core, modules...) =>
      appRun.getRun $rootScope, core, modules
    # dependencies for run block
    runBlock.$inject = ['$rootScope', 'app_core_service'].concat @runServices
    runBlock
