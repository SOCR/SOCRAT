'use strict'

( ->
  clusteringMainCtrl = (dataService) ->

    init = =>

      @dataType = ''
      @transforming = off
      @transformation = ''
      @transformations = []
      @affinityMatrix = null
      @data_types = dataService.getDataTypes()

      @getData = getData

    ############

    getData = =>
      dataService.getData().then (dataFrame) ->
        @dataType = dataFrame.dataType
        # TODO: main controller logic

    ############

    init()
    return

  clusteringMainCtrl.$inject = ['app_analysis_clustering_dataService']
  angular.module('app_analysis_clustering').controller('clusteringMainCtrl', clusteringMainCtrl)
)()
