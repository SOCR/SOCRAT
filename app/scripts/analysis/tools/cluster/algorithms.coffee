'use strict'

algorithms = (msgService) ->

  algorithms = [
    name: 'K-Means'
    params: [
      k: [2..10]
      distance: 'Euclidean'
      initialisation: 'Forgy'
    ]
  ,
    name: 'Spectral cluster'
    params: [
      k: [2..10]
      distance: 'Euclidean'
      initialisation: 'Forgy'
    ]
  ]

  ############

  getNames: ->
    algorithms.map (el) -> el.name

  getDataTypes: ->
    msgService.getSupportedDataTypes()

algorithms.$inject = ['app_analysis_cluster_msgService']
angular
  .module('app_analysis_cluster')
  .factory('app_analysis_cluster_algorithms', algorithms)
