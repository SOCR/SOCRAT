'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class StatsMainCtrl extends BaseCtrl
  @inject 'app_analysis_stats_msgService',
  'app_analysis_stats_algorithms',
  '$timeout',
  '$scope'

  initialize: ->
    console.log("stats initialized")
    window.alert("stats initialized")