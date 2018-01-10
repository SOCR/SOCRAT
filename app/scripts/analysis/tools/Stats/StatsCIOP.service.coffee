'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_stats_CIOP
  @type: service
  @desc: calculate CI with one proportion
###


module.exports = class StatsCIOP extends BaseService
  @inject 'app_analysis_stats_msgService',
    '$timeout'

  initialize: ->
   @msgService = @app_analysis_stats_msgService
   @jstat = require('jStat').jStat
   @name = 'CI for One Proportion'
   @compAgents=[]
   @proportion = 0.2
   @success =20
   @size = 100
   @sizeMax=200
   @zscore = 1.96

   @confinterval = [] 
   @upbound = @confinterval[1]
   @lowbound = @confinterval[0]
   @alpha = 0.05
   @standarddev = 0

   @update()

   @parameter = 
      p: @proportion
      t: @size
      n: @success
      tMax: @sizeMax
      z: @zscore
      u: @upbound
      l: @lowbound
      a: @alpha

  saveData: (data) ->
    @success = data.popl
    @compAgents= data.target
    @size = data.total
    @update()
    return

  getName: () ->
   return @name

  getParams: () ->
    @parameter = 
      p: @proportion
      t: @size
      n: @success
      tMax: @sizeMax
      z: @zscore
      u: @upbound
      l: @lowbound
      a: @alpha
    return @parameter

  setParams: (newParams) ->
    @proportion = newParams.p
    @success = newParams.n
    @size = newParams.t
    @update()
    return
  
  setAlpha: (alphaIn) ->
    @alpha = alphaIn
    @update()
    return 

  update: () ->
    @proportion = @success/@size
    @standarddev = Math.sqrt((@proportion*(1-@proportion))/@size)
    @confinterval = @jstat.tci(@proportion, @alpha, @standarddev, @size)
    @upbound = @confinterval[1]
    @lowbound = @confinterval[0]
    @sizeMax = Math.max(@size, @sizeMax)
    return



