'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ClusterAlgorithms extends BaseModuleDataService
  @inject 'app_analysis_dimReduction_msgService',
    'app_analysis_dimReduction_tSne'
    '$interval'

  initialize: ->
    @msgManager = @app_analysis_dimReduction_msgService
    @tSne = @app_analysis_dimReduction_tSne

    @algorithms = [@tSne]

  ############

  getNames: -> @algorithms.map (alg) -> alg.getName()

  getParamsByName: (algName) ->
    (alg.getParams() for alg in @algorithms when algName is alg.getName()).shift()

  getDataTypes: ->
    @msgService.getSupportedDataTypes()

  dimRedRun: (algName, data, params) ->
    res = (alg.run(data, params) for alg in @algorithms when algName is alg.getName()).shift()

  reset: (algName) -> (alg.reset() for alg in @algorithms when algName is alg.getName()).shift()

  run: (algName, data, params, cb=null) ->
    res = @dimRedRun algName, data, params
    cb(res) if cb?
    # interval = @$interval =>
    #   if not res.done
    #     res = @clusterStep algName
    #     cb(res) if cb?
    #   else @$interval.cancel interval
    # , iterDelay

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
