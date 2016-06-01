'use strict'

AppMessageMap = require 'scripts/AppMessageMap.coffee'

###
# @name AppRun
# @desc Class for run block of application module
###

module.exports = class AppRun

  # include an instance of Core class
  @core: require 'scripts/core/Core.coffee'

  constructor: (@modules) ->
#  ($rootScope, core, db, getData, wrangleData, qualRobEst, qualRobEstView, instrPerfEval) ->
#  ($rootScope, core, db, getData, wrangleData, instrPerfEval, cluster, charts) ->

  getRun: ($rootScope) ->

    console.log 'APP RUN'

    core.setEventsMapping new AppMessageMap()


    # TODO: add dynamic start of modules and adding them to menus
#    for module in @modules



#    new Sandbox core, 'app_analysis_cluster',
#    cluster.setSb

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

    $rootScope.$on "$stateChangeSuccess", (scope, next, change) ->
      console.log 'APP: state change: '
      console.log arguments

    console.log 'run block of app module'
