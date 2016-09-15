'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ChartsMainCtrl extends BaseCtrl

  @inject '$scope'

  initialize: ->
    @_chart_data = null

    _updateData: () ->
      @chartData = @_chart_data

    @$scope.$on 'charts:graphDiv', (event, data) ->
      @_chart_data = data
      _updateData()
