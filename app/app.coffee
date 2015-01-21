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
  'ngSanitize'
  #'app.utils.importer'
  'app_core'
  'app_controllers'
  'app_directives'
  'app_filters'
  'app_services'
  'app_mediator'
  'app_database'
   # Analysis modules
  'app_analysis_getData'
  'app_analysis_qualRobEstView'
  'app_analysis_qualRobEst'
  #charts analysis
  'app_analysis_chartsView'
  'app_analysis_charts'
  'app_analysis_instrPerfEvalView'
  'app_analysis_instrPerfEval'
])

App.config([
  '$locationProvider'
  #urlRouterProvider is not required
  '$urlRouterProvider'
  '$stateProvider'
  ($locationProvider, $urlRouterProvider, $stateProvider) ->

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
      )
      .state('guide'
        url: '/guide'
        views:
          'main':
            templateUrl: 'partials/nav/guide-me.html'
          'sidebar':
            templateUrl: 'partials/projects.html'
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
            templateUrl: 'partials/analysis/getData/main.html'
          'sidebar':
            templateUrl: 'partials/analysis/getData/sidebar.html'
      )
      .state('getData.project'
        url: '/:projectId/:forkId'
        resolve:
          checkDb: ($stateParams, app_database_dv) ->
            res = app_database_dv.exists $stateParams.projectId + ':' + $stateParams.forkId
            console.log "does DB exist for this project? "+res
        views:
          'main':
            templateUrl: 'partials/analysis/getData/main.html'
          'sidebar':
            templateUrl: 'partials/analysis/getData/sidebar.html'
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
            templateUrl: 'partials/analysis/tools/instrPerfEvalView/main.html'
          'sidebar':
            templateUrl: 'partials/analysis/tools/instrPerfEvalView/sidebar.html'
      )
    .state('charts'
      url: '/charts/:projectId/:forkId'
      views:
        'main':
          templateUrl: 'partials/analysis/charts/main.html'
          controller: 'chartsMainCtrl'
        'sidebar':
          templateUrl: 'partials/analysis/charts/sidebar.html'
          controller: 'chartsSidebarCtrl'
    )
    # Without server side support html5 must be disabled.
    $locationProvider.html5Mode(false)

])

App.run([
  '$rootScope'
  'core'
  'app_database_constructor'
  'app_analysis_getData_constructor'
  'app_analysis_qualRobEst_constructor'
  'app_analysis_qualRobEstView_constructor'
  'app_analysis_instrPerfEval_constructor'
  'app_analysis_instrPerfEvalView_constructor'
  'app_analysis_chartsView_construct'
  'app_analysis_charts_construct'
  #'app.utils.importer'
  ($rootScope, core, db, getData, qualRobEst, qualRobEstView, instrPerfEval, instrPerfEvalView,charts,chartsView) ->
    map = [
      msgFrom: 'add numbers'
      scopeFrom: ['qualRobEstView']
      msgTo: 'add numbers'
      scopeTo: ['qualRobEst']
    ,
      msgFrom: 'numbers added'
      scopeFrom: ['qualRobEst']
      msgTo: 'numbers added'
      scopeTo: ['qualRobEstView']
    ,
      msgFrom: 'calculate'
      scopeFrom: ['instrPerfEvalView']
      msgTo: 'calculate'
      scopeTo: ['instrPerfEval']
    ,
      msgFrom: 'calculated'
      scopeFrom: ['instrPerfEval']
      msgTo: 'calculated'
      scopeTo: ['instrPerfEvalView']
    ,
      msgFrom: 'save table'
      scopeFrom: ['getData', 'app.utils.importer']
      msgTo: 'save table'
      scopeTo: ['database']
    ,
      msgFrom:'table saved'
      scopeFrom: ['database']
      msgTo: '234'
      scopeTo: ['qualRobEst']
    ,
      msgFrom: 'upload csv'
      scopeFrom: ['getData']
      msgTo: 'upload csv'
      scopeTo: ['app.utils.importer']
    ,
      msgFrom: 'get table'
      scopeFrom: ['instrPerfEvalView']
      msgTo: 'get table'
      scopeTo: ['database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['database']
      msgTo: 'take table'
      scopeTo: ['instrPerfEvalView']
    ,
    # When /getData handonstable is updated, DB needs to be updated with the lastest values.
      msgFrom: 'handsontable updated'
      scopeFrom: ['getData']
      msgTo: 'save table'
      scopeTo: ['database']
    ]

    core.setEventsMapping map

    core.register 'qualRobEstView', qualRobEstView
    core.start 'qualRobEstView'

    core.register 'qualRobEst', qualRobEst
    core.start 'qualRobEst'

    core.register 'chartsView', chartsView
    core.start 'chartsView'

    core.register 'charts', charts
    core.start 'charts'

    core.register 'instrPerfEvalView', instrPerfEvalView
    core.start 'instrPerfEvalView'

    core.register 'instrPerfEval', instrPerfEval
    core.start 'instrPerfEval'

    core.register 'getData', getData
    core.start 'getData'

    core.register 'database', db
    core.start 'database'

    #core.register 'importer', importer
    #core.start 'importer'

    $rootScope.$on "$stateChangeSuccess", (scope, next, change)->
      console.log 'APP: state change: '
      console.log arguments

    console.log 'run block of app module'
])

