'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ClusterSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_cluster_dataService', 'app_analysis_cluster_algorithms'

  # injected:
  # @dataType
  # @algorithms

  initialize: ->
    # set up data and algorithm-agnostic controls
    @useLabels = on
    @useAllData = on
    @reportAccuracy = on
    @clustering = off
    @cols = []
    @algorithmNames = getAlgorithms()

  getAlgorithms: ->
    @algorithms.getNames()

  getParameters: ->
    @dataService.getData().then (dataFrame) ->
      @dataType = dataFrame.dataType
      # TODO: sidebar controller logic
