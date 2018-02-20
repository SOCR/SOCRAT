'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleMainCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @DATA_TYPES = @dataService.getDataTypes()

    @title = 'My Module'
    @dataType = ''
    @dataPoints = null

    @$scope.$on 'mymodule:displayData',(event, dataFrame) =>
      @$timeout => @updateTableData(dataFrame)

  updateTableData: (dataFrame) ->
    if dataFrame?
      @dataPoint
      @dataPoints = dataFrame
