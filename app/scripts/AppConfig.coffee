'use strict'

Module = require 'scripts/Module/Module.coffee'
AppRoute = require 'scripts/AppRoute.coffee'
AppRun = require 'scripts/AppRun.coffee'

###
# @name AppConfig
# @desc Class for config block of application module
###
module.exports = class AppConfig

  # TODO: pass module list as structured object for defining menus in appRun?

  addModuleComponents: (modules = @moduleList.getAnalysisModules()) ->
    for module in modules

      # create single modules
      if module instanceof Module

        angModule = angular.module module.id

        moduleComponents = module.components
        # adding services
        for serviceName, service of moduleComponents.services
          console.log 'CORE: created service: ' + serviceName
          angModule.service serviceName, service

        console.log 'CORE: created module ' + module.id

      # if collection of modules, recursively create
      else @addModuleComponents (v for k, v of module)[0]

  constructor: (@moduleList) ->
    @addModuleComponents()

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
    #create new run block
    appRun = new AppRun @modules
    runBlock = () =>
      appRun.getRun()
    runBlock.$inject = ['$rootScope']
    runBlock
