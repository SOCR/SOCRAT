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
  'app.qualRobEstView'
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
          templateUrl:'partials/analysis/getData/main.html'
          controller:'getDataMainCtrl'
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
          templateUrl: 'partials/analysis/tools/qualRobEstView/main.html'
          controller: 'qualRobEstViewMainCtrl'
        'sidebar':
          templateUrl: 'partials/analysis/tools/qualRobEstView/sidebar.html'
          controller: 'qualRobEstViewSidebarCtrl'

  # Without server side support html5 must be disabled.
  $locationProvider.html5Mode(false)

])

App.run(['core', 'getData', 'qualRobEstView', (core, getData, qualRobEstView) ->

  map = [
    msgFrom: '000'
    msgTo: '123'
    scope: 'qualRobEst'
  ,
    msgFrom: '234'
    msgTo: '111'
    scope: 'qualRobEstView'
  ]

  core.setEventsMapping map

  core.register 'qualRobEstView', qualRobEstView
  core.start 'qualRobEstView'

  console.log 'run block of app module'
])

