'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ChartsMainCtrl extends BaseCtrl
  @inject '$scope'

  initialize: ->
    @chartData = null

    @$scope.$on 'charts:updateGraph', (event, data) =>
      @chartData = data
