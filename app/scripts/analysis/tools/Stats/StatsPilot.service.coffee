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
  @alpha = 0.05
  @success =20
  @compAgents=[]
  @size = 100
  @parameter = 
    p: @percentUnder
    r: @riskExceed
    d: @df
   
  #TODO for data driven model
  saveData: (data) ->
    """
    @success = data.popl
    @compAgents= data.target
    @size = data.total
    @update()
    """
    return

  getName: () ->
    return @name

  getParams: () ->
    @parameter = 
    p: @percentUnder
    r: @riskExceed
    d: @df
    return @parameter
    
  setParams: (newParams) ->
    @percentUnder = newParams.p
    @riskExceed = newParams.r
    @df = newParams.d
    @update()
    return
  
  setAlpha: (alphaIn) ->
    @alpha = alphaIn
    @update()
    return
    

  update: () ->
    return
    



