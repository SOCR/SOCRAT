'use strict'

( ->
  clusteringSidebarCtrl = (dataService) ->

    init = =>

      @ks = [params.minK..params.maxK]
      @affinities = params.affinities
      @gamma: gamma
      @sigma: sigma
      @nNeighbors: nNeighbors

      @cols = []
      @clustering = on
      @running = 'hidden'
      @uniqueLabels =
        labelCol: null
        num: null

      @k = @ks[0]
      @initMethod = @affinities[0]
      @useLabels = on
      @useAllData = on
      @reportAccuracy = on

    ############

    getParameters = =>
      dataService.getData().then (dataFrame) ->
        @dataType = dataFrame.dataType
    # TODO: sidebar controller logic

    ############

    init()
    return

  clusteringMainCtrl.$inject = ['app_analysis_clustering_dataService']
  angular.module('app_analysis_clustering').controller('clusteringSidebarCtrl', clusteringMainCtrl)
)()
