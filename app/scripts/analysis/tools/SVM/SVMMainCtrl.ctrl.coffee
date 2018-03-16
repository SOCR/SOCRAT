'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class SVMMainCtrl extends BaseCtrl
  @inject 'app_analysis_svm_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @app_analysis_svm_dataService
    @DATA_TYPES = @dataService.getDataTypes()

    @title = 'SVM'
    @dataType = ''
    @dataPoints = null

    @$scope.$on 'svm:displayData',(event, dataFrame) =>
      @$timeout => @updateTableData(dataFrame)

  updateTableData: (dataFrame) ->
    if dataFrame?
      @dataPoint
      @dataPoints = dataFrame
