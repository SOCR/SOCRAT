'use strict'

###
# @name AppConfig
# @desc Class for config block of application module
###

module.exports = class AppRoute

  @modules: []

  constructor: ($locationProvider, $urlRouterProvider, $stateProvider) ->

    console.log 123

    $urlRouterProvider.when('/', '/')
    .otherwise('/home')

    $stateProvider
    .state('welcome'
      url: '/welcome'
      views:
        'main':
          template: require('partials/welcome.jade')()
    )
    .state('home'
      url:'/home'
      views:
        'main':
          template: require('partials/nav/home.jade')()
        'sidebar':
          template: require('partials/projects.jade')()
    )
    .state('guide'
      url: '/guide'
      views:
        'main':
          template: require('partials/nav/guide-me.jade')()
        'sidebar':
          template: require('partials/projects.jade')()
    )
    .state('contact'
      url: '/contact'
      views:
        'main':
          template: require('partials/nav/contact.jade')()
    )
    .state('getData'
      url: '/getData'
      views:
        'main':
          template: require('partials/analysis/getData/main.jade')()
        'sidebar':
          template: require('partials/analysis/getData/sidebar.jade')()
    )
    .state('getData.project'
      url: '/:projectId/:forkId'
      resolve:
        checkDb: ($stateParams, app_database_dv) ->
          res = app_database_dv.exists $stateParams.projectId + ':' + $stateParams.forkId
          console.log "does DB exist for this project? "+res
      views:
        'main':
          template: require('partials/analysis/getData/main.jade')()
        'sidebar':
          templateUrl: require('partials/analysis/getData/sidebar.jade')()
    )
    #      .state('wrangleData'
    #        url: '/wrangleData'
    #        views:
    #          'main':
    #            templateUrl: 'partials/analysis/wrangleData/main.html'
    #          'sidebar':
    #            templateUrl: 'partials/analysis/wrangleData/sidebar.html'
    #      )
    #      .state('instrperfeval'
    #        url: '/tools/instrperfeval'
    #        views:
    #          'main':
    #            templateUrl: 'partials/analysis/tools/psychometrics/instrPerfEval/main.html'
    #          'sidebar':
    #            templateUrl: 'partials/analysis/tools/psychometrics/instrPerfEval/sidebar.html'
    #      )
    #      .state('kmeans'
    #        url: '/tools/kmeans'
    #        views:
    #          'main':
    #            templateUrl: 'partials/analysis/tools/machineLearning/kMeans/main.html'
    #          'sidebar':
    #            templateUrl: 'partials/analysis/tools/machineLearning/kMeans/sidebar.html'
    #      )
    #    .state('spectrClustr'
    #      url: '/tools/spectrClustr'
    #      views:
    #        'main':
    #          templateUrl: 'partials/analysis/tools/machineLearning/spectralClustering/main.html'
    #        'sidebar':
    #          templateUrl: 'partials/analysis/tools/machineLearning/clustspectralClusteringering/sidebar.html'
    #    )
    #    .state('cluster'
    #      url: '/tools/cluster'
    #      views:
    #        'main':
    #          template: require('partials/analysis/tools/cluster/main.jade')()
    #        'sidebar':
    #          template: require('partials/analysis/tools/cluster/sidebar.jade')()
    #    )
    #      .state('charts'
    #        url: '/charts'
    #        views:
    #          'main':
    #            templateUrl: 'partials/analysis/charts/main.html'
    #          'sidebar':
    #            templateUrl: 'partials/analysis/charts/sidebar.html'
    #      )

    # Without server side support html5 must be disabled.
    $locationProvider.html5Mode(false)

# inject dependencies
AppRoute.$inject = ['$locationProvider', '$urlRouterProvider', '$stateProvider']
