#'use strict'
#
#clusterMainCtrl = (dataService) ->
#
#  init = =>
#
#    @dataType = ''
#    @transforming = off
#    @transformation = ''
#    @transformations = []
#    @affinityMatrix = null
#    @data_types = dataService.getDataTypes()
#
#    @getData = getData
#
#  ############
#
#  getData = =>
#    dataService.getData().then (dataFrame) ->
#      @dataType = dataFrame.dataType
#      # TODO: main controller logic
#
#  ############
#
#  init()
#  return
#
#clusterMainCtrl.$inject = ['app_analysis_cluster_dataService']
#angular.module('app_analysis_cluster').controller('clusterMainCtrl', clusterMainCtrl)
