'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class DimensionReductionMainCtrl extends BaseCtrl
  @inject 'app_analysis_dimension_reduction_dataSetConfig',
          'app_analysis_dimension_reduction_dataService',
          '$timeout',
          '$scope'

  initialize: ->
    @dataService = @app_analysis_dimension_reduction_dataService
    @dataSet = @app_analysis_dimension_reducion_dataSetConfig

    # @receivedLink = @dataSet.getURLs()[0]
    @receivedLink = 'https://projector.tensorflow.org/?config=https://raw.githubusercontent.com/TomWBush/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/allDataSets.json'

    # @$scope.$on 'dimensionReduction:link', (event, receivedLink) =>
    #   @receivedLink = receivedLink
