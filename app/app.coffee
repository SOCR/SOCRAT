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
  'app.controllers'
  'app.directives'
  'app.filters'
  'app.services'
  'app.mediator'
  'ngSanitize'
  'app.getData'
])

App.config([
  '$routeProvider'
  '$locationProvider'
($routeProvider, $locationProvider) ->

  console.log "config block of app module"
  $routeProvider
    #main nav bar
    .when('/home',{templateUrl:'partials/main.html'})
    .when('/guide',{templateUrl:'partials/nav/guide-me.html'})
    .when('/contact',{templateUrl:'partials/nav/contact.html'})
    .when('/welcome',{templateUrl:'partials/welcome.html'})
    
    #analysis tools routes
    .when('/getData', {
      templateUrl: 'partials/analysis/getData/main.html'})
    .when('/cleanData',{
      templateUrl:'partials/analysis/cleanData/main.html'})
    
    #.when('/charts',{templateUrl:"partials/analysis/charts/main.html"})
    #.when('/results',{templateUrl:"partials/analysis/results/main.html"})
    # Catch all
    #.otherwise({redirectTo: '/welcome'})


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

