'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ModelerMainCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @DATA_TYPES = @dataService.getDataTypes()

    @title = 'Modeler module'
    @dataType = ''
    @dataPoints = null
    @means = null
    @assignments = null

    @$scope.$on 'modeler:updateDataPoints', (event, data) =>
      #@showresults = off if @showresults is on
      # safe enforce $scope.$digest to activate directive watchers
      @$timeout => @updateChartData(data)

    @$scope.$on 'modeler:updateDataType', (event, dataType) =>
      @dataType = dataType


    updateChartData: (data) ->
      if data.dataPoints?
        @dataPoints = data.dataPoints
      @means = data.means
      @assignments = data.labels
