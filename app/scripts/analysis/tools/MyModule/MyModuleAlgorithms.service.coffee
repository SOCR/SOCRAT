'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ClusterAlgorithms extends BaseModuleDataService
  @inject 'socrat_analysis_myModule_msgService',
    'socrat_analysis_myModule_kMeans'
    'socrat_analysis_myModule_spectral'
    '$interval'

  initialize: ->
    @msgManager = @socrat_analysis_myModule_msgService
    @kmeans = @socrat_analysis_myModule_kMeans
    @spectral = @socrat_analysis_myModule_spectral

    @algorithms = [@kmeans, @spectral]

  ############

  getNames: -> @algorithms.map (alg) -> alg.getName()

  getParamsByName: (algName) ->
    (alg.getParams() for alg in @algorithms when algName is alg.getName()).shift()

  getDataTypes: ->
    @msgService.getSupportedDataTypes()

  clusterStep: (algName, data, k, init, distance) ->
    res = (alg.step(data, k, init, distance) for alg in @algorithms when algName is alg.getName()).shift()

  reset: (algName) -> (alg.reset() for alg in @algorithms when algName is alg.getName()).shift()

  cluster: (algName, data, k, init, distance, iterDelay=0, cb=null) ->
    res = @clusterStep algName, data, k, init, distance
    cb(res) if cb?
    interval = @$interval =>
      if not res.done
        res = @clusterStep algName
        cb(res) if cb?
      else @$interval.cancel interval
    , iterDelay

  evaluateAccuracy: (labels, trueLabels) ->
    accuracy = {}
    uniqueLabels = (trueLabels) -> trueLabels.filter (x, i, a) -> i is a.indexOf x
    # unique labels available for assignment
    uniqueEstLabels = (labels) -> labels.filter (x, i, a) -> i is a.indexOf x

    for k in uniqueLabels
    # get true indices for label k
      kTrueLabelIdxs = (i for x, i in trueLabels when x is k)
      # get calculated labels by true indices
      kEstLabels = (x for x, i in labels when i in kTrueLabelIdxs) # numeric
      estLabelCounts = uniqueEstLabels.map (uniqueEstLabel) ->
        # count number of occurrences for each unique estimated label
        counts = kEstLabels.reduce (n, val) ->
          n + (val is uniqueEstLabel)
        , 0
        counts
      # find first most abundant label index
      mostFrequentEstLabelIdx = estLabelCounts.indexOf Math.max.apply(null, estLabelCounts) # numeric
      currentEstLabel = uniqueEstLabels[mostFrequentEstLabelIdx]
      # remove label that was taken
      uniqueEstLabels.splice mostFrequentEstLabelIdx, 1
      accuracy[k] = estLabelCounts[mostFrequentEstLabelIdx] / kTrueLabelIdxs.length

    accs = (acc for own label, acc of accuracy)
    accuracy['average'] = accs.reduce((r, s) -> r + s) / accs.length
    accuracy
