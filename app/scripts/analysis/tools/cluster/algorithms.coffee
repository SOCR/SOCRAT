'use strict'

( ->
  clustering = (msgManager) ->

    algorithms = [
      name: 'K-Means'
      params: [
        k: [2..10]
        distance: 'Euclidean'
        initialisation: 'Forgy'
      ]
    ,
      name: 'Spectral cluster'
      params: []
    ]

    ############

    getAlgorithms: ->
      algorithms

    getDataTypes: ->
      msgManager.getSupportedDataTypes()

  dataService.$inject = ['app_analysis_clustering_msgService']
  angular
    .module('app_analysis_clustering')
    .factory('app_analysis_clustering_clustering', clustering)
)()
