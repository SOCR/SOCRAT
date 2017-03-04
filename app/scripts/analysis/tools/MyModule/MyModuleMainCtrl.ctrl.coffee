'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ClusterMainCtrl extends BaseCtrl
  @inject 'app_analysis_cluster_dataService', '$timeout', '$scope'

  initialize: ->
  
#      @showresults = off if @showresults is on
      # safe enforce $scope.$digest to activate directive watchers
      
