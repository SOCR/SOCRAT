'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class NormalDist extends BaseService

  initialize: () ->


    @name = 'Normal'


  getName: () ->
    return @name


  getChartData: (data) ->
    data = data.dataPoints
    
   

