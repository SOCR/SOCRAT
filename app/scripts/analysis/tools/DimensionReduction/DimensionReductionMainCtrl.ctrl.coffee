'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class DimensionReductionMainCtrl extends BaseCtrl
  @inject 'app_analysis_dimension_reduction_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @app_analysis_dimension_reduction_dataService
    @receivedLink = 'https://projector.tensorflow.org/?config=https://raw.githubusercontent.com/SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/'
    @receivedLink += BaseCtrl.fileSets[0]

    @$scope.$on 'dimensionReduction:link', (event, receivedLink) =>
      @receivedLink = receivedLink
      console.log(@receivedLink)
