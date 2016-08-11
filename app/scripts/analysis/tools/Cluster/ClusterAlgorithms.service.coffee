'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ClusterAlgorithms extends BaseModuleDataService
  @inject 'app_analysis_cluster_msgService'

  initialize: ->

    @msgManager = @app_analysis_cluster_msgService

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
