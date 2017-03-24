'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class StatisticMainCtrl extends BaseCtrl
  @inject 'app_analysis_statistic_msgService','$timeout', '$scope'

  initialize: ->
    @powerAnalysis = require 'powercalc'
    @msgService = @app_analysis_powercalc_msgService
    @title = 'Statistic Analysis Module'