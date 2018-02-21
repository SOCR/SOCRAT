'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_cluster_spectral
  @type: service
  @desc: Performs spectral clustering using NJW algorithm
  “On Spectral Clustering: Analysis and an algorithm” Andrew Y. Ng, Michael I. Jordan, Yair Weiss, 2001
###

module.exports = class ClusterSpectral extends BaseService
  @inject '$timeout', 'app_analysis_cluster_metrics'

  initialize: () ->
    @metrics = @app_analysis_cluster_metrics

    @name = 'Spectral clustering'
    @data = {}
    @timer = null
    @params = {}
#      k: [2..10]
#      distance: @metrics.getNames()

  getName: -> @name
  getParams: -> @params

  step: ->
