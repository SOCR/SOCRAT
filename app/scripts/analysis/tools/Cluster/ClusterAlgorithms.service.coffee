'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ClusterAlgorithms extends BaseModuleDataService
  @inject 'app_analysis_cluster_msgService',
    'app_analysis_cluster_kMeans'
    'app_analysis_cluster_spectral'

  initialize: ->
    @msgManager = @app_analysis_cluster_msgService
    @kmeans = @app_analysis_cluster_kMeans
    @spectral = @app_analysis_cluster_spectral

    @algorithms = [@kmeans, @spectral]

  ############

  getNames: -> @algorithms.map (alg) -> alg.getName()

  getParamsByName: (algName) ->
    (alg.getParams() for alg in @algorithms when algName is alg.getName())[0]

  getDataTypes: ->
    @msgService.getSupportedDataTypes()
