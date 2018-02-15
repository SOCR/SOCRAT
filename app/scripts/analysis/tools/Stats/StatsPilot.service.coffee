'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_stats_Pilot
  @type: service
  @desc: pilot study
###


module.exports = class StatsPilot extends BaseService
  @inject 'app_analysis_stats_msgService',
    '$timeout'

  initialize: ->
   @msgService = @app_analysis_stats_msgService
   @name = 'Pilot Study'
   

  saveData: (data) ->
    return

  getName: () ->
    return @name

  getParams: () ->
    return
    
  setParams: (newParams) ->
    return
  
  setAlpha: (alphaIn) ->
    return
    

  update: () ->
    return
    



