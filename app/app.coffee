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
  'ui.router'
  'ui.router.compat'
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
  #charts module
  'app_analysis_charts'
  # Analysis modules
  'app_analysis_getData'
  'app_analysis_wrangleData'
#  'app_analysis_qualRobEstView'
#  'app_analysis_qualRobEst'
  'app_analysis_instrPerfEval'
  'app_analysis_kMeans'
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
      .state('wrangleData'
        url: '/wrangleData'
        views:
          'main':
            templateUrl: 'partials/analysis/wrangleData/main.html'
          'sidebar':
            templateUrl: 'partials/analysis/wrangleData/sidebar.html'
      )
#      .state('tools'
#        url: '/tools'
#        views:
#          'main':
#            templateUrl: 'partials/analysis/tools/instrPerfEval/main.html'
#          'sidebar':
#            templateUrl: 'partials/analysis/tools/instrPerfEval/sidebar.html'
#      )
      .state('tools'
        url: '/tools'
        views:
          'main':
            templateUrl: 'partials/analysis/tools/kMeans/main.html'
          'sidebar':
            templateUrl: 'partials/analysis/tools/kMeans/sidebar.html'
      )
      .state('charts'
        url: '/charts/:projectId/:forkId'
        views:
          'main':
            templateUrl: 'partials/analysis/charts/main.html'
          'sidebar':
            templateUrl: 'partials/analysis/charts/sidebar.html'
      )

    # Without server side support html5 must be disabled.
    $locationProvider.html5Mode(false)
])

App.run([
  '$rootScope'
  'core'
  'app_database_constructor'
  'app_analysis_getData_constructor'
  'app_analysis_wrangleData_constructor'
#  'app_analysis_qualRobEst_constructor'
#  'app_analysis_qualRobEstView_constructor'
  'app_analysis_instrPerfEval_constructor'
  'app_analysis_kMeans_constructor'
  'app_analysis_charts_constructor'
  #'app.utils.importer'
#  ($rootScope, core, db, getData, wrangleData, qualRobEst, qualRobEstView, instrPerfEval) ->
  ($rootScope, core, db, getData, wrangleData, instrPerfEval, kMeans) ->

    map = [
#      msgFrom: 'add numbers'
#      scopeFrom: ['qualRobEstView']
#      msgTo: 'add numbers'
#      scopeTo: ['qualRobEst']
#    ,
#      msgFrom: 'numbers added'
#      scopeFrom: ['qualRobEst']
#      msgTo: 'numbers added'
#      scopeTo: ['qualRobEstView']
#    ,
      msgFrom: 'save data'
      scopeFrom: ['getData', 'wrangleData']
      msgTo: 'save table'
      scopeTo: ['database']
#    ,
#      msgFrom:'table saved'
#      scopeFrom: ['database']
#      msgTo: '234'
#      scopeTo: ['qualRobEst']
#    ,
#      msgFrom: 'upload csv'
#      scopeFrom: ['getData']
#      msgTo: 'upload csv'
#      scopeTo: ['app.utils.importer']
    ,
      # TODO: make message mapping dynamic #SOCRFW-151
      msgFrom: 'get table'
      scopeFrom: ['instrPerfEval']
      msgTo: 'get table'
      scopeTo: ['database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['database']
      msgTo: 'take table'
      scopeTo: ['instrPerfEval']
    ,
      msgFrom: 'get data'
      scopeFrom: ['kMeans']
      msgTo: 'get table'
      scopeTo: ['database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['database']
      msgTo: 'take data'
      scopeTo: ['kMeans']
    ,
      msgFrom: 'get data'
      scopeFrom: ['wrangleData']
      msgTo: 'get table'
      scopeTo: ['database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['database']
      msgTo: 'wrangle data'
      scopeTo: ['wrangleData']
    ,
      msgFrom: 'get table'
      scopeFrom: ['chartsView']
      msgTo: 'get table'
      scopeTo: ['database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['database']
      msgTo: 'take table'
      scopeTo: ['chartsView']
    ]

    core.setEventsMapping map

#    core.register 'qualRobEstView', qualRobEstView
#    core.start 'qualRobEstView'
#
#    core.register 'qualRobEst', qualRobEst
#    core.start 'qualRobEst'

    core.register 'getData', getData
    core.start 'getData'

    core.register 'database', db
    core.start 'database'

    core.register 'wrangleData', wrangleData
    core.start 'wrangleData'

    core.register 'instrPerfEval', instrPerfEval
    core.start 'instrPerfEval'

    core.register 'kMeans', kMeans
    core.start 'kMeans'

    #core.register 'importer', importer
    #core.start 'importer'

    $rootScope.$on "$stateChangeSuccess", (scope, next, change)->
      console.log 'APP: state change: '
      console.log arguments

    console.log 'run block of app module'
])

