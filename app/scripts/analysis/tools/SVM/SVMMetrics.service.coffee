'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class SVMMetrics extends BaseModuleDataService

  initialize: ->

    @metrics = [
      name: 'linear'
    ,
      name: 'poly'
    ,
      name: 'rbf'
    ,
      name: 'sigmoid'
    ]

  getKernelNames: ->
    @metrics.map (metric) -> metric.name
