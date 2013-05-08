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

( $locationProvider,$urlRouterProvider,$stateProvider) ->

  console.log "config block of app module"
  $urlRouterProvider.when('/','/')
    .otherwise('/home')

  $stateProvider
    .state 'welcome'
      url:'/welcome'
      views:
        'main':
          templateUrl:'partials/welcome.html'

    .state 'home'
      url:'/home'
      views:
        'main':
          templateUrl:'partials/nav/home.html'
        'sidebar':
          templateUrl:'partials/projects.html'
          controller:'projectCtrl'

    .state 'guide'
      url:'/guide'
      views:
        'main':
          templateUrl:'partials/nav/guide-me.html'
        'sidebar':
          templateUrl:'partials/projects.html'
          controller:'projectCtrl'

    .state 'contact'
      url:'/contact'
      views:
        'main':
          templateUrl:'partials/nav/contact.html'

    .state 'getData'
      url:'/getData'
      views:
        'main':
          templateUrl:'partials/nav/guide-me.html'
          controller:'getDataMainCtrl'
        'sidebar':
          templateUrl:'partials/analysis/getData/sidebar.html'
          controller:'getDataSidebarCtrl'

    .state 'cleanData'
      url:'/cleanData'
      views:
        'main':
          templateUrl:'partials/analysis/cleanData/main.html'
        'sidebar':
          templateUrl:'partials/analysis/cleanData/sidebar.html'

  # Without server side support html5 must be disabled.
  $locationProvider.html5Mode(false)

])

App.run(['core','getData', (core,getData)->
  console.log arguments
####
# Test code
####
  _modules =
    0 :
      id : 'getData'
      creator: getData
      opt:{}

  _len = Object.keys(_modules).length
  while(_len--)
    core.register _modules[0].id, _modules[_len].creator

  core.start 'getData'
  _len = Object.keys(_modules).length
  while(_len--)
    console.log "module started"
    #core.startAll ()->
      # this will go as view update to show the app is ready.
    #  console.log "all modules have been started"

  console.log "run block of app module"

])

