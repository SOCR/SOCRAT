'use strict'

ModuleDataService = require 'scripts/BaseClasses/ModuleDataService.coffee'

module.exports = class ClusterAlgorithms extends ModuleDataService
  @inject 'app_analysis_cluster_msgService'

  # injected:
  # @msgManager

  initialize: ->

    @algorithms = [
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
    @algorithms.map (algorithm) -> algorithm.name

  getDataTypes: ->
    @msgService.getSupportedDataTypes()
