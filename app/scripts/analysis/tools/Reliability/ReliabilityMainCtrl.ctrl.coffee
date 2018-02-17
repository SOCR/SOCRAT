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
    @result = ''

    @showMetric = {}
    @metrics = @tests.getMetricNames().map (metric) -> metric.toLowerCase().replace(/[^\w\s]/gi, '')
    @showMetric[metric] = true for metric in @metrics

    # TODO: look for workaround https://github.com/angular/angular.js/issues/13960
    try
      $('.socrat-reliability-metric').each (idx, el) =>
        # console.log el
        try
          $(el).attr("uib-collapse", "mainArea.showMetric['#{@metrics[idx]}']")
        # console.log $(el).attr()
    catch e
      console.log 'ERROR' + e

    # default output
    @setShowMetric @metrics[0]

    @$scope.$on 'reliability:updateDataType', (event, dataType) =>
      @dataType = dataType

    @$scope.$on 'reliability:showResults', (event, obj) =>
      @setShowMetric obj.metric.toLowerCase().replace(/[^\w\s]/gi, '')
      @showResults obj.data

  setShowMetric: (metric) ->
    for key of @showMetric
      @showMetric[key] = metric isnt key

  prettifyArrayOutput: (arr) ->
    if arr?
      arr = arr.map (x) -> x.toFixed 3
      '[' + arr.toString().split(',').join('; ') + ']'

  showResults: (res) ->
    if not isNaN(Number(res))
      @result = Number(res).toFixed(3)
    else if res.confIntervals
      cAlpha = Number(res.cAlpha)
      if not isNaN cAlpha
        @result = Number(res.cAlpha).toFixed(3)
        @cronAlphaIdInterval = @prettifyArrayOutput(res.confIntervals.id)
        @cronAlphaKfInterval = @prettifyArrayOutput(res.confIntervals.kf)
        @cronAlphaLogitInterval = @prettifyArrayOutput(res.confIntervals.logit)
        @cronAlphaBootstrapInterval = @prettifyArrayOutput(res.confIntervals.bootstrap)
        @cronAlphaAdfInterval = @prettifyArrayOutput(res.confIntervals.adf)
      else
        @result = 'ERROR'
    else if typeof res is 'string'
      @result = res
    else @result = 'ERROR'
