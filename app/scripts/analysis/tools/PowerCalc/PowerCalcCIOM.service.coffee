'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
	@name: app_analysis_powercalc_CIOM
	@type: service
	@desc: Performs Confidence Interval for One Mean analysis
###


module.exports = class PowerCalcCIOM extends BaseService
	@inject 'app_analysis_powerCalc_msgService',
		'$timeout'

	initialize: ->
		@jStat = require("jStat").jStat
		@msgService = @app_analysis_powerCalc_msgService
		@name = 'CI for One Mean'
		@populations = null

		#variables needed for CI for One Mean
		@CIOMN = 100
		@CIOMNMax = 200
		@CIOMMean = 0
		@CIOMMeanMax = 10
		@CIOMVariance = 1
		@CIOMStDev = 1
		@CIOMSigmaMax = 20
		@CIOMAlpha = 0.01
		@CIOMTScore = 0
		@CIOMLowerBound = 0
		@CIOMUpperBound = 0
		@CIOMMode = "Two Tailed"
		@CIOMModes = ["Two Tailed", "One Tailed"]

		#data to observe
		@parameters =
			n: @CIOMN
			nMax: @CIOMNMax
			mu: @CIOMMean
			meanMax: @CIOMMeanMax
			sigma: @CIOMStDev
			sigmaMax: @CIOMSigmaMax
			t: @CIOMTScore
			lowBound: @CIOMLowerBound
			upBound: @CIOMUpperBound
			mode: @CIOMMode

		@CIOMUpdate()

	saveData: (data) ->
		@populations = data.popl
		@CIOMReceiveData()

	setAlpha: (alphaIn) ->
		@CIOMAlpha = alphaIn
		@CIOMUpdate()
		return

	getName: () ->
		return @name

	getParams: () ->
		@parameters =
			n: @CIOMN
			nMax: @CIOMNMax
			mu: Number(@CIOMMean.toFixed(3))
			meanMax: Number(@CIOMMeanMax.toFixed(3))
			sigma: Number(@CIOMStDev.toFixed(3))
			sigmaMax: Number(@CIOMSigmaMax.toFixed(3))
			t: Number(@CIOMTScore.toFixed(3))
			lowBound: Number(@CIOMLowerBound.toFixed(3))
			upBound: Number(@CIOMUpperBound.toFixed(3))
			mode: @CIOMMode

	setParams: (newParams) ->
		@CIOMN = Number(newParams.n)
		@CIOMMean = Number(newParams.mu)
		@CIOMStDev = Number(newParams.sigma)
		@CIOMMode = newParams.mode
		@CIOMUpdate()
		return

	reset: () ->
		@CIOMN = 100
		@CIOMNMax = 200
		@CIOMMean = 0
		@CIOMMeanMax = 10
		@CIOMVariance = 1
		@CIOMStDev = 1
		@CIOMSigmaMax = 20
		@CIOMAlpha = 0.01
		@CIOMTScore = 0
		@CIOMLowerBound = 0
		@CIOMUpperBound = 0
		@CIOMMode = "Two Tailed"
		@CIOMModes = ["Two Tailed", "One Tailed"]
		@CIOMUpdate()
		return

	CIOMReceiveData: () ->
		item = Object.keys(@populations)[0]
		@CIOMN = @populations[item].length
		@CIOMMean = @getMean(@getSum(@populations[item]), @populations[item].length)
		@CIOMVariance = @getVariance(@populations[item], @CIOMMean)
		@CIOMStDev = Math.sqrt(@CIOMVariance)
		@CIOMUpdate()
		return

	CIOMCheckRange: () ->
		@CIOMNmax = Math.max(@CIOMN, @CIOMNMax)
		@CIOMMeanMax = Math.max(@CIOMMean, @CIOMMeanMax)
		@CIOMSigmaMax = Math.max(@CIOMStDev, @CIOMSigmaMax)
		return

	CIOMUpdate: () ->
		df = @CIOMN - 1
		if @CIOMMode is "Two Tailed"
			alpha = @CIOMAlpha * 0.5
		else
			alpha = @CIOMAlpha
		@CIOMTScore = Math.abs(@jStat.studentt.inv(alpha, df))
		@CIOMLowerBound = @CIOMMean - @CIOMStDev * @CIOMTScore
		@CIOMUpperBound = @CIOMMean + @CIOMStDev * @CIOMTScore
		@CIOMCheckRange()
		return

	getVariance: (values, mean) ->
		temp = 0
		numberOfValues = values.length
		while( numberOfValues--)
			temp += Math.pow( (parseInt(values[numberOfValues]) - mean), 2 )
		return temp / values.length

	getSum: (values) ->
		values.reduce (previousValue, currentValue) -> parseFloat(previousValue) + parseFloat(currentValue)

	getMean: (valueSum, numberOfOccurrences) ->
		valueSum / numberOfOccurrences
