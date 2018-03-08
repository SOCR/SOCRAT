'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class Dist extends BaseService
    @inject 'socrat_analysis_modeler_getParams'
    initialize: () ->
        @helpers = @socrat_analysis_modeler_getParams

    

    quantile: (p) ->
        

