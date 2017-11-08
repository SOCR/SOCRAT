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
   @msgService = @app_analysis_powerCalc_msgService
   @jstat = require('jStat').jStat
   @name = 'DAHEE'
   @populations = null
   @compAgents=[]
   @sampleproportion = 0.2
   @success =20
   @samplesize = 100
   @zscore = 1.96

   @confinterval = [0,1] 
   @upbound = @confinterval[1]
   @lowbound = @confinterval[0]
   @ciAlpha = 0.05
   @populations = {}
   @standarddev = 0
   @cilevel = 0.95

   @parameter = 
      p: @sampleproportion
      t: @samplesize
      n: @success
      z: @zscore
      u: @upbound
      l: @lowbound
      ci: @confinterval
      a: @ciAlpha
      sd: @standarddev
      cl: @cilevel



  saveData: (data) ->
    console.log 'saveData in service'
    @populations = data.popl
    @compAgents= data.target
    @samplesize = data.total
    @daheeReceiveData()
    return

  getName: () ->
   return @name

  getParams: () ->
    @parameter = 
      p: @sampleproportion
      t: @samplesize
      n: @success
      u: @upbound
      l: @lowbound
      ci: @confinterval
      a: @ciAlpha
      sd: @standarddev
      cl: @cilevel
    return @parameter

  setParams: (newParams) ->
    @sampleproportion = newParams.p
    @success = newParams.n
    @samplesize = newParams.t
    @upbound = newParams.u
    @lowbound = newParams.l
    @confinterval =newParams.ci
    @ciAlpha = newParams.a
    @standarddev = newParams.sd
    @cilevel = newParams.cl
    return
   
  daheeReceiveData: () ->
    console.log 'receiving done'
    @success = @populations[@compAgents]
    @samplesize = @samplesize
    @sampleproportion = @success/@samplesize
    @cilevel = 1- @ciAlpha
    @standarddev = Math.sqrt((@sampleproportion*(1-@sampleproportion))/(@samplesize-df)
    @confinterval = @jstat.tci(@sampleproportion, @ciAlpha, @standarddev, @samplesize)
    @upbound = @confinterval[1]
    @lowbound = @confinterval[0]
    return

  setAlpha: (alphaIn) ->
    @ciAlpha = alphaIn
    return

  # savePower: (newParams) ->
  #   @onePropPower = newParams.power
  #   @onePropPowerTon()
  #   return



