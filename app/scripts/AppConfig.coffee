'use strict'

AppRoute = require 'scripts/AppRoute.coffee'
Core = require 'scripts/core/Core.coffee'

###
# @name AppConfig
# @desc Class for config block of application module
###
module.exports = class AppConfig

  constructor: (@modules) ->
    for module in @modules
      angModule = angular.module module.id

      moduleComponents = module.components
      # adding services
      for serviceName, service of moduleComponents.services
        console.log 'core: starting service: ' + serviceName
        angModule.service serviceName, service

      console.log 'CORE: created module ' + module.id

  getConfig: ->

    # TODO: pass module list to router

    appRoute = new AppRoute @modules
    router = appRoute.getRouter
    # inject dependencies
    router.$inject = ['$locationProvider', '$urlRouterProvider', '$stateProvider']
    router.modules = @modules
    router

