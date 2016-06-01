'use strict'

AppRoute = require 'scripts/AppRoute.coffee'
AppRun = require 'scripts/AppRun.coffee'

###
# @name AppConfig
# @desc Class for config block of application module
###
module.exports = class AppConfig

  # TODO: pass module list as structured object for defining menus in appRun?

  addModuleComponents: (modules) ->
    for module in modules
      angModule = angular.module module.id

      moduleComponents = module.components
      # adding services
      for serviceName, service of moduleComponents.services
        console.log 'core: starting service: ' + serviceName
        angModule.service serviceName, service

      console.log 'CORE: created module ' + module.id

  constructor: (@modules) ->
    @addModuleComponents @modules.analysis
    @addModuleComponents @modules.tools

  getConfigBlock: ->
    # create new router
    appRoute = new AppRoute @modules
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
