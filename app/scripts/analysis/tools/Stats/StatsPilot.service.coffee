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
    @pilotDFMax = 100;
    @pilotPercentUnderMax = 100;
    @compAgents=[]
    @size = 100
    @percentUnder = 20;
    @riskExceed = 0.1;
    @df = 80;
    @parameter =
      p: @percentUnder
      r: @riskExceed
      d: @df
      rMax: @pilotRiskExceedMax
      dfMax: @pilotDFMax
      pMax: @pilotPercentUnderMax
    @update('pctUnder')

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
      rMax: @pilotRiskExceedMax
      dfMax: @pilotDFMax
      pMax: @pilotPercentUnderMax
    return @parameter

  setParams: (newParams) ->
    @percentUnder = newParams.p
    @riskExceed = newParams.r
    @df = newParams.d
    @update(newParams.tar)
    return

  checkRange: () ->
    @pilotRiskExceedMax= Math.max(@pilotRiskExceedMax, @parameter.r)
    @pilotDFMax = Math.max(@pilotDFMax, @parameter.d)
    return

  setAlpha: (alphaIn) ->
    @alpha = alphaIn
    @update('pctUnder')
    return

  update: (tar) ->
    input =
      tar: tar
      pctUnder: @percentUnder
      risk: @riskExceed
      df: @df
    params = @powerCalc.pilot_handle(input)
    @percentUnder = params.pctUnder
    @riskExceed = params.risk
    @df = params.df
    @checkRange()
    return




