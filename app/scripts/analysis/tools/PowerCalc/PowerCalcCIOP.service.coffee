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
   @name = 'DAHEE'
   @populations = null
   @compAgents=[]
   @sampleproportion = 0.2
   @success =20
   @samplesize = 100
   @zscore = 1.96
   @upbound = 0
   @lowbound = 0
   @confinterval = [] 
   @ciAlpha = 0.05
   @clevel = 0.95
   @populations = {}

   @parameter = 
      p: @sampleproportion
      n: @success
      t: @samplesize
      z: @zscore
      u: @upbound
      l: @lowbound
      ci: @confinterval



  saveData: (data) ->
    @populations = data.popl
    @compAgents= data.target
    @daheeReceiveData()
    return


  getName: () ->
   return @name


  getParams: () ->
    @parameter = 
      p: @sampleproportion
      n: @success
      z: @zscore
      u: @upbound
      l: @lowbound
      ci : @confinterval
    return @parameter


  setParams: (newParams) ->
    @sampleproportion = newParams.p
    @success = newParams.n
    @samplesize = newParams.t
    @zscore = newParams.z
    @upbound = newParams.u
    @lowbound = newParams.l
    @confinterval =newParams.ci
    return

  # savePower: (newParams) ->
  #   @onePropPower = newParams.power
  #   @onePropPowerTon()
  #   return

  daheeReceiveData: () ->
    totalnumber = 0
    for i in Object.keys(@populaions)
      totalnumber=totalnumber + @populations[i]
    @success = @populations[@compAgents]
    @samplesize = totalnumber
    @sampleproportion = @success/@samplesize
    @daheeUpdate()
    return

  setAlpha: (alphaIn) ->
    @ciAlpha = alphaIn
    @daheeUpdate()
    return

  reset: () ->
    @sampleproportion = 0
    @success = 0
    @zscore = 1.96
    @upbound = 0
    @lowbound = 0
    @confint = []
    @daheeUpdate() 
    return

  daheeUpdate:() ->
    @upbound = @sampleproportion+@zscore*sqrt((@sampleproportion*(1-@sampleproportion))/@samplesize)
    @lowbound = @sampleproportion-@zscore*sqrt((@sampleproportion*(1-@sampleproportion))/@samplesize)
    @confinterval = [@lowbound, @upbound]


