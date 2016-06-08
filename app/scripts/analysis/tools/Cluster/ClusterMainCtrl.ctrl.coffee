'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

appControllers = angular.module 'app_controllers'

module.exports = class ClusterMainCtrl extends BaseCtrl
  @inject '$scope', 'appSidebarState'

  initialize: ->
#initial width is set .col-md-9
    @width = 'col-md-9'

    #updating main view
    @$scope.$on 'update view', =>
      if @appSidebarState.sidebar is 'visible' and @appSidebarState.history is 'hidden'
        @width = 'col-md-9'
      else
        @width = 'col-md-11'

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
