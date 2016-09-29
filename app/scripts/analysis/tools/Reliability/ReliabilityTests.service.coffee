'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ReliabilityTests extends BaseModuleDataService

  initialize: ->

    @metrics = [
      name: "Cronbach's Alpha"
      method: @cronbachAlpha
    ,
      name: 'Intraclass correlation coefficient'
      method: @icc
    ,
      name: 'Split-Half Reliability coefficient'
      method: @splitHalfReliability
    ,
      name: 'Kuder–Richardson Formula 20 (KR-20)'
      method: @kr20
    ]

  cronbachAlpha: () ->

  icc: () ->

  splitHalfReliability: () ->

  kr20: () ->
