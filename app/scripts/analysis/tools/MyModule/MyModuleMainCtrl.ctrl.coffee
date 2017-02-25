'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ClusterMainCtrl extends BaseCtrl
  @inject 'app_analysis_cluster_dataService', '$timeout', '$scope'

  initialize: ->
    
    @$scope.$on 'cluster:updateDataPoints', (event, data) =>
#      @showresults = off if @showresults is on
      # safe enforce $scope.$digest to activate directive watchers
      
