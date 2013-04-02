'use strict'

# Declare app level module which depends on filters, and services
App = angular.module('app', [
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

($routeProvider, $locationProvider, config) ->

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
    .otherwise({redirectTo: '/welcome'})

  # Without server side support html5 must be disabled.
  $locationProvider.html5Mode(false)

])

#App.run(['core','getData', (core,getData)->
#  console.log "run block of app module"
#  sb = {}
#  getData = new getData(sb)
#  getData.setSb(sb)
#
#])
