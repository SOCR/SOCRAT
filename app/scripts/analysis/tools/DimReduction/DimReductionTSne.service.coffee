'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_dimReduction_tSne
  @type: service
  @desc: Performs t-SNE dimensionality reduction
###

module.exports = class DimReductionTSne extends BaseService
  @inject '$timeout'

  initialize: () ->
    @jsfeat = require 'jsfeat'
    @tsne = require 'tsne-js'

    @name = 't-SNE'
    @timer = null
    @lables = null
    @iter = 0
    @done = off
    @maxIter = 200
    @perplexity = 10

    @distances = [
      'euclidean',
      'manhattan',
      'jaccard (boolean data)',
      'dice (boolean data)'
    ]

    #runtime variables
    @data = null

    # module parameters
    @params =
      distance: @distances
      perplexity: @perplexity

  getName: -> @name
  getParams: -> @params

  getUniqueLabels: (labels) -> labels.filter (x, i, a) -> i is a.indexOf x

  arrayEqual: (x, y) ->
    a = x.slice().sort()
    b = y.slice().sort()
    a.length is b.length and a.every (elem, i) -> elem is b[i]

  run: (params, inputData) ->
    model = new @tsne
      dim: 2
      perplexity: params.perplexity
      earlyExaggeration: 4.0
      learningRate: 100.0
      nIter: @maxIter
      metric: params.metric

    model.init
      data: inputData,
      type: 'dense'

    [error, iter] = model.run()

    output = model.getOutput()

  reset: ()->
    @done = off
    @iter = 0
