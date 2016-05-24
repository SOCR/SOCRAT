'use strict'

###
# @name AppRun
# @desc Class for run block of application module
###

module.exports = class AppRun
  constructor: ($rootScope, core, cluster) ->
#  ($rootScope, core, db, getData, wrangleData, qualRobEst, qualRobEstView, instrPerfEval) ->
#  ($rootScope, core, db, getData, wrangleData, instrPerfEval, cluster, charts) ->

    console.log 'APP RUN'

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
#    ,
#      msgFrom: 'get data'
#      scopeFrom: ['kMeans']
#      msgTo: 'get table'
#      scopeTo: ['database']
#    ,
#      msgFrom: 'take table'
#      scopeFrom: ['database']
#      msgTo: 'take data'
#      scopeTo: ['kMeans']
    ,
      msgFrom: 'cluster:getData'
      scopeFrom: ['cluster']
      msgTo: 'get table'
      scopeTo: ['database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['database']
      msgTo: 'cluster:takeData'
      scopeTo: ['cluster']
#    ,
#      msgFrom: 'get data'
#      scopeFrom: ['spectrClustr']
#      msgTo: 'get table'
#      scopeTo: ['database']
#    ,
#      msgFrom: 'take table'
#      scopeFrom: ['database']
#      msgTo: 'take data'
#      scopeTo: ['spectrClustr']
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
      scopeFrom: ['charts']
      msgTo: 'get table'
      scopeTo: ['database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['database']
      msgTo: 'take table'
      scopeTo: ['charts']

    ]

    #    core.setEventsMapping map

    #    core.register 'qualRobEstView', qualRobEstView
    #    core.start 'qualRobEstView'
    #
    #    core.register 'qualRobEst', qualRobEst
    #    core.start 'qualRobEst'

    #    core.register 'getData', getData
    #    core.start 'getData'

    #    core.register 'database', db
    #    core.start 'database'
    #
    #    core.register 'wrangleData', wrangleData
    #    core.start 'wrangleData'
    #
    #    core.register 'instrPerfEval', instrPerfEval
    #    core.start 'instrPerfEval'

    #    core.register 'kMeans', kMeans
    #    core.start 'kMeans'
    #
    #    core.register 'spectrClustr', spectrClustr
    #    core.start 'spectrClustr'

    #    core.register 'cluster', cluster
    #    core.start 'cluster'

    #    core.register 'charts', charts
    #    core.start 'charts'

    #core.register 'importer', importer
    #core.start 'importer'

    # add module to the list of Tools to appear in Tools tab dropdown
    tools = [
      id: 'instrPerfEval'
      name: 'Instrument Performance Evaluation'
      url: '/tools/instrperfeval'
    ,
      id: 'cluster'
      name: 'Clustering'
      url: '/tools/cluster'
#    ,
#      id: 'kMeans'
#      name: 'k-Means Clustering'
#      url: '/tools/kmeans'
#    ,
#      id: 'spectrClustr'
#      name: 'Spectral Clustering'
#      url: '/tools/spectrClustr'
    ]

    # subscribe for request from MainCtrl for list of tool modules
    $rootScope.$on 'app:get_tools', (event, args) ->
      $rootScope.$broadcast 'app:set_tools', tools

    $rootScope.$on "$stateChangeSuccess", (scope, next, change)->
      console.log 'APP: state change: '
      console.log arguments

    console.log 'run block of app module'

AppRun.$inject = [
  '$rootScope'
  'app_core_service'
#  'app_database_constructor'
#  'app_analysis_getData_constructor'
#  'app_analysis_wrangleData_constructor'
#  'app_analysis_qualRobEst_constructor'
#  'app_analysis_qualRobEstView_constructor'
#  'app_analysis_instrPerfEval_constructor'
#  'app_analysis_kMeans_constructor'
#  'app_analysis_spectrClustr_constructor'
  'app_analysis_cluster_starter'
#  'app_analysis_charts_constructor'
#'app.utils.importer'
]
