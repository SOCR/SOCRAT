'use strict'

# Declare app level module which depends on filters, and services
App = angular.module('app', [
  'ngCookies'
  'ngResource'
  'app.controllers'
  'app.directives'
  'app.filters'
  'app.services'
])

App.config([
  '$routeProvider'
  '$locationProvider'

($routeProvider, $locationProvider, config) ->

  $routeProvider
    .when('/todo', {templateUrl: 'partials/todo.html'})
    .when('/home',{templateUrl:'partials/nav/home.html'})
    .when('/guide',{templateUrl:'partials/nav/guide-me.html'})
    .when('/contact',{templateUrl:'partials/nav/contact.html'})
    
    #analysis tools routes
    .when('/raw-data', {templateUrl: 'partials/analysis/raw-data/main.html'})
    .when('/derived-data',{
      templateUrl:'partials/analysis/derived-data/main.html'})
    #.when('/charts',{templateUrl:"partials/analysis/charts/main.html"})
    #.when('/results',{templateUrl:"partials/analysis/results/main.html"})
    # Catch all
    .otherwise({redirectTo: '/home'})

  # Without server side support html5 must be disabled.
  $locationProvider.html5Mode(false)
])
