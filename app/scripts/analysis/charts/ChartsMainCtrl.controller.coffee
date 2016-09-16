'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ChartsMainCtrl extends BaseCtrl
  @inject '$scope'

  initialize: ->
    @chartData = null

    @$scope.$on 'charts:graphDiv', (event, data) =>
      @chartData = data
