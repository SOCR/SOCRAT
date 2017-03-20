'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ModelerMainCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService',
    'socrat_analysis_modeler_getParams',
    '$timeout',
    '$scope'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @DATA_TYPES = @dataService.getDataTypes()

    @title = 'Modeling Module'
    @dataType = ''
    @dataPoints = null
    @assignments = null
    @distribution = 'Normal'
    @stats = null
    @getParams = @socrat_analysis_modeler_getParams

    @$scope.$on 'modeler:updateDataPoints', (event, data) =>
      #@showresults = off if @showresults is on
      # safe enforce $scope.$digest to activate directive watchers
      @$timeout => @updateChartData(data)

    @$scope.$on 'modeler:updateDataType', (event, dataType) =>
      console.log("broadcast occurered, updating datatTYPE")
      @dataType = dataType


  updateChartData: (data) ->
    if data.dataPoints?
      console.log("updatating chartData")
      console.log(data)
      @stats = @getParams.getParams(data)
      @distribution = data.distribution
      console.log(@distribution)
      @chartData = data
      console.log("distribution:" + data.distribution.name)



