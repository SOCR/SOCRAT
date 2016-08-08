'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ClusterMainCtrl extends BaseCtrl
  @inject 'app_analysis_cluster_dataService'

  # injected:
  # @dataType

  initialize: ->
    @title = 'Clustering module'
    @dataType = ''
    @transforming = off
    @transformation = ''
    @transformations = []
    @affinityMatrix = null
#    @data_types = @dataService.getDataTypes()

  getData: ->
    @dataService.getData().then (dataFrame) ->
      @dataType = dataFrame.dataType
      # TODO: main controller logic
