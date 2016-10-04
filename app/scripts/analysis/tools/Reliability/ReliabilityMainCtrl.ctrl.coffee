'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ReliabilityMainCtrl extends BaseCtrl
  @inject 'app_analysis_reliability_dataService',
    'app_analysis_reliability_tests'
    '$timeout'
    '$scope'

  initialize: ->
    @dataService = @app_analysis_reliability_dataService
    @DATA_TYPES = @dataService.getDataTypes()
    @tests = @app_analysis_reliability_tests
    @dataType = ''
    @metrics = @tests.getMetricNames()
    @showMetric =
      cronAlpha: false
      icc: true
      splitHalf: true
      kr20: true

    @$scope.$on 'reliability:updateDataType', (event, dataType) =>
      @dataType = dataType

    @$scope.$on 'reliability:updateMetric', (event, metric) =>
      switch metric
        when @metrics[0] then @setShowMetric 'cronAlpha'
        when @metrics[1] then @setShowMetric 'icc'
        when @metrics[2] then @setShowMetric 'splitHalf'
        when @metrics[3] then @setShowMetric 'kr20'

    @$scope.$on 'reliability:showResults', (event, data) =>
      @showResults data

  setShowMetric: (metric) ->
    for key of @showMetric
      @showMetric[key] = metric isnt key

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
