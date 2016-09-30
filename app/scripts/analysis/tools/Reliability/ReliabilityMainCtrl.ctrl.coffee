'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ReliabilityMainCtrl extends BaseCtrl
  @inject 'app_analysis_reliability_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @app_analysis_reliability_dataService
    @DATA_TYPES = @dataService.getDataTypes()
    @tests = @app_analysis_reliability_tests
    @dataType = ''

  prettifyArrayOutput: (arr) ->
    if arr?
      arr = arr.map (x) -> x.toFixed 3
      '[' + arr.toString().split(',').join('; ') + ']'

  showResults: (data) ->
    cAlpha = Number data.cronAlpha

    if not isNaN(cAlpha)
      @cronAlpha = cAlpha.toFixed(3)
      @cronAlphaIdInterval = @prettifyArrayOutput(data.idInterval)
      @cronAlphaKfInterval = @prettifyArrayOutput(data.kfInterval)
      @cronAlphaLogitInterval = @prettifyArrayOutput(data.logitInterval)
      @cronAlphaBootstrapInterval = @prettifyArrayOutput(data.bootstrapInterval)
      @cronAlphaAdfInterval = @prettifyArrayOutput(data.adfInterval)

    @icc = Number(data.icc).toFixed(3)
    @kr20 = if data.kr20 is 'Not a binary data' then data.kr20 else Number(data.kr20).toFixed(3)

    @splitHalfCoef = Number(data.adjRCorrCoef).toFixed(3)

  $scope.$on 'reliability:updateDataType', (event, dataType) ->
    @dataType = dataType

  $scope.$on 'reliability:showResults', (event, data) ->
    @showResults data
