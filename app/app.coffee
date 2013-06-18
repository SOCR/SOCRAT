'use strict'
###
  NOTE: Order of the modules injected into "app" module decides
  which module gets initialized first.
  In this case, ngCookies config block is executed first, followed by
  ngResource and so on. Finally config block of "app" is executed.
  Then the run block is executed in the same order.
  Run block of "app" is executed in the last.
###
App = angular.module('app', [
  'ui'
  'ui.compat'
  'ngCookies'
  'ngResource'
  'app.core'
  'app.getData'
  'app.qualRobEst'
  'app.controllers'
  'app.directives'
  'app.filters'
  'app.services'
  'app.mediator'
  'ngSanitize'
])

App.config([
  '$locationProvider'
  '$urlRouterProvider'
  '$stateProvider'

( $locationProvider, $urlRouterProvider, $stateProvider) ->

  console.log "config block of app module"
  $urlRouterProvider.when('/','/')
    .otherwise('/home')

  $stateProvider
    .state 'welcome'
      url: '/welcome'
      views:
        'main':
          templateUrl: 'partials/welcome.html'

    .state 'home'
      url:'/home'
      views:
        'main':
          templateUrl: 'partials/nav/home.html'
        'sidebar':
          templateUrl: 'partials/projects.html'
          controller: 'projectCtrl'

    .state 'guide'
      url: '/guide'
      views:
        'main':
          templateUrl: 'partials/nav/guide-me.html'
        'sidebar':
          templateUrl: 'partials/projects.html'
          controller: 'projectCtrl'

    .state 'contact'
      url: '/contact'
      views:
        'main':
          templateUrl: 'partials/nav/contact.html'

    .state 'getData'
      url: '/getData'
      views:
        'main':
          templateUrl: 'partials/nav/guide-me.html'
          controller: 'getDataMainCtrl'
        'sidebar':
          templateUrl: 'partials/analysis/getData/sidebar.html'
          controller: 'getDataSidebarCtrl'

    .state 'cleanData'
      url: '/cleanData'
      views:
        'main':
          templateUrl: 'partials/analysis/cleanData/main.html'
        'sidebar':
          templateUrl: 'partials/analysis/cleanData/sidebar.html'

    .state 'tools'
      url: '/tools'
      views:
        'main':
          templateUrl: 'partials/analysis/tools/qualRobEst/main.html'
          controller: 'qualRobEstMainCtrl'
        'sidebar':
          templateUrl: 'partials/analysis/tools/qualRobEst/sidebar.html'
          controller: 'qualRobEstSidebarCtrl'

  # Without server side support html5 must be disabled.
  $locationProvider.html5Mode(false)

])

App.run(['core', 'getData', 'qualRobEst', (core, getData, qualRobEst) ->

  map =
    '123': '234'

  core.setMapping map

  core.register 'qualRobEst', qualRobEst
  core.start 'qualRobEst'

  console.log 'run block of app module'
])

