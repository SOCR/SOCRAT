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
    @customData = null

    @$scope.$on 'svm:updateDataPoints', (event, data) =>
      console.log data
      @$timeout => @organizeSend(data)

  organizeSend: (data) ->
    if data? and data.dataPoints?
      @customData = data.dataPoints.map (point, i) ->
        if data.labels?
          label = data.labels[i]
        else
          label = 0
        point = 
          x_c: point[0]
          y_c: point[1]
          c: label
        return point