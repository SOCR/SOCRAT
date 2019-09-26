'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class DimensionReductionMainCtrl extends BaseCtrl
  @inject 'app_analysis_dimension_reduction_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @app_analysis_dimension_reduction_dataService
    @receivedLink = ""

    @$scope.$on 'dimensionReduction:link', (event, receivedLink) =>
      @receivedLink = receivedLink
      console.log(@receivedLink)
