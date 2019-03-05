'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ClassificationAlgorithms extends BaseModuleDataService
  @inject 'app_analysis_classification_msgService',
    'app_analysis_classification_csvc',
    'app_analysis_classification_knn'
    '$interval'
    # Will have to update; instead of spectral/kmeans, will do all
    # options that are offered by svm npm

  initialize: ->
    @dataService = @app_analysis_classification_dataService
    @msgManager = @app_analysis_classification_msgService
    @csvc = @app_analysis_classification_csvc
    @knn = @app_analysis_classification_knn

    @algorithms = [@csvc, @knn]

    # load ml-svm module
    @svmModel = require 'ml-svm'

  ############

  getNames: -> @algorithms.map (alg) -> alg.getName()

  getParamsByName: (algName) ->
    (alg.getParams() for alg in @algorithms when algName is alg.getName()).shift()

  setParamsByName: (algName, dataIn) ->
    (alg.setParams(dataIn) for alg in @algorithms when algName is alg.getName()).shift()

  passDataByName: (algName, dataIn) ->
    (alg.saveData(dataIn) for alg in @algorithms when algName is alg.getName()).shift()

  trainingByName: (algName, dataIn) ->
    (alg.train(dataIn) for alg in @algorithms when algName is alg.getName()).shift()

  getDataTypes: ->
    @msgService.getSupportedDataTypes()





  reset: (algName) -> (alg.reset() for alg in @algorithms when algName is alg.getName()).shift()
