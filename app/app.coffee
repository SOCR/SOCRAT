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
  'app.utils.importer'
])

App.config([
  '$locationProvider'
  #urlRouterProvider is not required
  '$urlRouterProvider'
  '$stateProvider'

( $locationProvider, $urlRouterProvider, $stateProvider) ->

  console.log "config block of app module"
  $urlRouterProvider.when('/','/')
    .otherwise('/home')

  $stateProvider
    .state('welcome'
      url: '/welcome'
      views:
        'main':
          templateUrl: 'partials/welcome.html'
    )
    .state('home'
      url:'/home'
      views:
        'main':
          templateUrl: 'partials/nav/home.html'
        'sidebar':
          templateUrl: 'partials/projects.html'
          controller: 'projectCtrl'
    )
    .state('guide'
      url: '/guide'
      views:
        'main':
          templateUrl: 'partials/nav/guide-me.html'
        'sidebar':
          templateUrl: 'partials/projects.html'
          controller: 'projectCtrl'
    )

    .state('contact'
      url: '/contact'
      views:
        'main':
          templateUrl: 'partials/nav/contact.html'
    )
    .state('getData'
      url: '/getData'
      views:
        'main':
          templateUrl:'partials/analysis/getData/main.html'
          controller:'getDataMainCtrl'
        'sidebar':
          templateUrl: 'partials/analysis/getData/sidebar.html'
          controller: 'getDataSidebarCtrl'
    )
    .state('getData.project'
      url: '/:projectId/:forkId'
      resolve:
        checkDb:($stateParams,database)->
          res = database.exists $stateParams.projectId+":"+$stateParams.forkId
          console.log database
          # alert res
      views:
        'main':
          templateUrl:'partials/analysis/getData/main.html'
          controller:'getDataMainCtrl'
        'sidebar':
          templateUrl: 'partials/analysis/getData/sidebar.html'
          controller: 'getDataSidebarCtrl'
    )
    .state('cleanData'
      url: '/cleanData'
      views:
        'main':
          templateUrl: 'partials/analysis/cleanData/main.html'
        'sidebar':
          templateUrl: 'partials/analysis/cleanData/sidebar.html'
    )
    .state('tools'
      url: '/tools'
      views:
        'main':
          templateUrl: 'partials/analysis/tools/qualRobEstView/main.html'
          controller: 'qualRobEstViewMainCtrl'
        'sidebar':
          templateUrl: 'partials/analysis/tools/qualRobEstView/sidebar.html'
          controller: 'qualRobEstViewSidebarCtrl'
    )
  # Without server side support html5 must be disabled.
  $locationProvider.html5Mode(false)

])

App.run([
  '$rootScope'
  'core'
  'db'
  'getData'
  'qualRobEstView'
  'qualRobEst'
  'app.utils.importer'
  ($rootScope, core, db, getData, qualRobEstView, qualRobEst,importer) ->

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
    ,
      msgFrom:'save table'
      scopeFrom: ['getData','app.utils.importer']
      msgTo:'save table'
      scopeTo:['database']
    ,
      msgFrom:'table saved'
      scopeFrom: ['database']
      msgTo:'234'
      scopeTo:['qualRobEst']
    ,
      msgFrom:'upload csv'
      scopeFrom: ['getData']
      msgTo:'upload csv'
      scopeTo:['app.utils.importer']
    ]

    core.setEventsMapping map

    core.register 'qualRobEstView', qualRobEstView
    core.start 'qualRobEstView'

    core.register 'qualRobEst', qualRobEst
    core.start 'qualRobEst'

    core.register 'getData', getData
    core.start 'getData'

    core.register 'db', db
    core.start 'db'

    core.register 'importer', importer
    core.start 'importer'

    $rootScope.$on "$stateChangeSuccess", (scope,next,change)->
      console.log arguments
      console.log "teststestse"

    console.log 'run block of app module'

])

