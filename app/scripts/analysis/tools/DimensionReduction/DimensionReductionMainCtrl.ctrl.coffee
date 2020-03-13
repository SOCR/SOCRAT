'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class DimensionReductionMainCtrl extends BaseCtrl
  @inject 'app_analysis_dimension_reduction_getDataSetConfig',
          'app_analysis_dimension_reduction_dataService',
          '$timeout',
          '$scope'

  initialize: ->
    @dataService = @app_analysis_dimension_reduction_dataService
    @dataSet = @app_analysis_dimension_reduction_getDataSetConfig

    @receivedLink = @dataSet.getURLs()[0]

    @$scope.$on 'dimensionReduction:link', (event, receivedLink) =>
      @receivedLink = receivedLink
