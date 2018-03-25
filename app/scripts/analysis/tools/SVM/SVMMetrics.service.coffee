'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class SVMMetrics extends BaseModuleDataService

  initialize: ->

    @metrics = [
      name: 'Linear'
    ,
      name: 'Poly'
    ,
      name: 'RBF'
    ,
      name: 'Sigmoid'
    ]

  getKernelNames: ->
    @metrics.map (metric) -> metric.name