'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_cluster_kMeans
  @type: service
  @desc: Performs k-means clustering
###

module.exports = class ClusterKMeans extends BaseService
  @inject '$timeout', 'app_analysis_cluster_metrics'

  initialize: () ->
    @metrics = @app_analysis_cluster_metrics

    @name = 'K-means'
    @data = {}
    @timer = null
    @params =
      k: [2..10]
      distance: @metrics.getNames()
      init: ['Forgy', 'Random patition', 'k-means++']

  getName: -> @name
  getParams: -> @params

  step: ->
