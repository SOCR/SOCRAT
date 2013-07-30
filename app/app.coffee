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
  'app.qualRobEst'
  'app.controllers'
  'app.directives'
  'app.filters'
  'app.services'
  'app.mediator'
  'ngSanitize'
  'app.db'
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
          templateUrl: 'partials/analysis/tools/qualRobEstView/main.html'
          controller: 'qualRobEstViewMainCtrl'
        'sidebar':
          templateUrl: 'partials/analysis/tools/qualRobEstView/sidebar.html'
          controller: 'qualRobEstViewSidebarCtrl'

  # Without server side support html5 must be disabled.
  $locationProvider.html5Mode(false)

])

App.run([
  'core'
  'database'
  'getData'
  'qualRobEstView'
  'qualRobEst'
  (core, database, getData, qualRobEstView, qualRobEst) ->

    map = [
      msgFrom: '111'
      scopeFrom: ['qualRobEstView']
      msgTo: '123'
      scopeTo: ['qualRobEst']
    ,
      msgFrom: '234'
      scopeFrom: ['qualRobEst']
      msgTo: '000'
      scopeTo: ['qualRobEstView']
    ]

    core.setEventsMapping map

    core.register 'qualRobEstView', qualRobEstView
    core.start 'qualRobEstView'

    core.register 'qualRobEst', qualRobEst
    core.start 'qualRobEst'

    console.log 'run block of app module'

    colA = ["a","a","b","b","c"]
    colB = [0,1,2,3,4]
    tab1 = [
      {name:"A", values:colA, type:"nominal"}
      {name:"B", values:colB, type:"numeric"}
    ]
    database.create tab1,"test"

    test = database.getTable "test"
    console.log test

    database.addListener
      "table": "test"
      "fn":(msg,data)->
        console.log msg
        console.log data
        console.log "Eureka"

    setTimeout ->
        database.addColumn "C", colA, "nominal", "test"
      ,4000
])

