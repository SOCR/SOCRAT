'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ClusterAlgorithms extends BaseModuleDataService
  @inject 'app_analysis_powerclac_msgService',
    'app_analysis_powercalc_allService'

  initialize: ->
    @msgManager = @app_analysis_powercalc_msgService
    @cfap = @app_analysis_cluster_allService

    @algorithms = [@cfap]

  ############

  getNames: -> @algorithms.map (alg) -> alg.getName()

  getParamsByName: (algName) ->
    (alg.getParams() for alg in @algorithms when algName is alg.getName()).shift()

  getDataTypes: ->
    @msgService.getSupportedDataTypes()

  
