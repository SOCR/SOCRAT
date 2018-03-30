'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class SVMAlgorithms extends BaseModuleDataService
  @inject 'app_analysis_svm_msgService',
    'app_analysis_svm_csvc'
    '$interval'
    # Will have to update; instead of spectral/kmeans, will do all
    # options that are offered by svm npm

  initialize: ->
    @dataService = @app_analysis_svm_dataService
    @msgManager = @app_analysis_svm_msgService
    @csvc = @app_analysis_svm_csvc

    @algorithms = [@csvc]

    # load ml-svm module
    @svmModel = require 'ml-svm'

  ############

  getNames: -> @algorithms.map (alg) -> alg.getName()

  getParamsByName: (algName) ->
    (alg.getParams() for alg in @algorithms when algName is alg.getName()).shift()

  getDataTypes: ->
    @msgService.getSupportedDataTypes()

  reset: (algName) -> (alg.reset() for alg in @algorithms when algName is alg.getName()).shift()
