'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ClusterSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_cluster_dataService', 'app_analysis_cluster_algorithms'

  initialize: ->
    @dataService = @app_analysis_cluster_dataService
    @algorithms = @app_analysis_cluster_algorithms
    # set up data and algorithm-agnostic controls
    @useLabels = on
    @useAllData = on
    @reportAccuracy = on
    @clustering = off
    @cols = []
    @dataType = null

  getAlgorithms: ->
    @algorithms.getNames()

  getParameters: ->
    @dataService.getData().then (dataFrame) ->
      @dataType = dataFrame.dataType
      # TODO: sidebar controller logic
