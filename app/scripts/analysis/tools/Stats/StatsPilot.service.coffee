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
    @powerCalc = require 'powercalc'
    @name = 'Pilot Study'
    @alpha = 0.05
    @success =20
    @pilotRiskExceedMax = 1;
    @pilotDFMax = 80;
    @pilotPercentUnderMax = 100;
    @compAgents=[]
    @size = 100
    @percentUnder = 20;
    @riskExceed = 0.1;
    @df = 0;
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

  checkRange: () ->
    @pilotRiskExceedMax= Math.max(@pilotRiskExceedMax, @parameter.r)
    @pilotDFMax = Math.max(@pilotDFMax, @parameter.d)
    return

  setAlpha: (alphaIn) ->
    @alpha = alphaIn
    @update()
    return

  update: () ->
    input =
      p: @percentUnder
      r: @riskExceed
      d: @df
    params = @powerCalc.pilot_handle(input)
      # TODO: update everything
    @parameter.p = params.p
    @parameter.r = params.r
    @parameter.d = params.d
    @checkRange()
    return




