#'use strict'
#
#clusterSidebarCtrl = (dataService, algorithms) ->
#
#  init = =>
#
#    # set up data and algorithm-agnostic controls
#    @useLabels = on
#    @useAllData = on
#    @reportAccuracy = on
#    @clustering = off
#    @cols = []
#    @algorithms = getAlgorithms()
#
#  ############
#
#  getAlgorithms = =>
#    algorithms.getNames()
#
#  getParameters = =>
#    dataService.getData().then (dataFrame) ->
#      @dataType = dataFrame.dataType
#      # TODO: sidebar controller logic
#
#  ############
#
#  init()
#  return
#
#clusterSidebarCtrl.$inject = ['app_analysis_cluster_dataService', 'app_analysis_cluster_algorithms']
#angular.module('app_analysis_cluster').controller('clusterSidebarCtrl', clusterSidebarCtrl)
