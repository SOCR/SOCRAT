'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

###
# @name AppConfig
# @desc Class for config block of application module
###

module.exports = class AppRoute

  constructor: (@modules) ->

  linkStatic: ($stateProvider) ->
    $stateProvider
    .state 'home',
      url:'/home'
      views:
        'main':
          template: require('partials/nav/home.jade')()
        'sidebar':
          template: require('partials/projects.jade')()

    .state 'guide',
      url: '/guide'
      views:
        'main':
          template: require('partials/nav/guide-me.jade')()
        'sidebar':
          template: require('partials/projects.jade')()

    .state 'contact',
      url: '/contact'
      views:
        'main':
          template: require('partials/nav/contact.jade')()


  linkDynamic: ($stateProvider, modules=@modules) =>

    for module in modules
      if module instanceof Module
        # check if module has state
        if module.state?.url?
          $stateProvider.state module.id,
            url: module.state.url
            views:
              'main':
                template: module.state.mainTemplate()
              'sidebar':
                template: module.state.sidebarTemplate()
      else @linkDynamic $stateProvider, (v for k, v of module)[0]

  getRouter: ($locationProvider, $urlRouterProvider, $stateProvider) ->

    $urlRouterProvider.when('/', '/')
    .otherwise('/home')

    # add states for static components
    @linkStatic $stateProvider

    # dynamically add state for analysis/tool modules
    @linkDynamic $stateProvider

    # Without server side support html5 must be disabled.
    $locationProvider.html5Mode(false)

    console.log 'app: routing is set up'
