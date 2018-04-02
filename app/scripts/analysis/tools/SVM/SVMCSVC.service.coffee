'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_svm_csvc
  @desc: Performs SVM classification (C formulation)
###

module.exports = class SVMCSVC extends BaseService
  @inject '$timeout', 'app_analysis_svm_metrics'

  initialize: () ->
    @metrics = @app_analysis_svm_metrics
    @jsfeat = require 'jsfeat'

    @name = 'C-SVC'
    exponents = [-4..5]
    @cs = (Math.pow 10,num for num in exponents)
    @lables = null

    #runtime variables
    @features = null
    @labels = null

    # Variables for Graphing Service



    # module hyperparameters
    @params =
      c: @cs
      kernel: @metrics.getKernelNames()

  getName: -> @name
  getParams: -> @params

  saveData: (data) ->
    @features = data.features
    @lables = data.labels
    console.log features
    console.log labels

  setParams: (newParams) ->
    @params = newParams
    return


  getUniqueLabels: (labels) -> labels.filter (x, i, a) -> i is a.indexOf x

  initLabels: (l, k) ->
    labels = []
    labels.push Math.floor(Math.random() * k) for i in [0..l]
    labels

  reset: ()->
    @done = off
    @iter = 0
