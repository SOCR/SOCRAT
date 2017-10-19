'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_powercalc_CIOP
  @type: service
  @desc: calculate CI with one proportion
###


module.exports = class PowerCalcCIOP extends BaseService
  @inject 'app_analysis_powerCalc_msgService',
    '$timeout'

  initialize: ->
   console.log "dahee service initialized!!"
   @msgService = @app_analysis_powerCalc_msgService
   @name = 'DAHEE'

   # TODO: add data

  getName: () ->
   return @name

   # TODO: add getParams