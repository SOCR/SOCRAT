'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class StatsMainCtrl extends BaseCtrl
	@inject 'app_analysis_stats_msgService',
	'app_analysis_stats_algorithms',
	'$timeout',
	'$scope'

	initialize: ->

		# required modules
		@d3 = require 'd3'
		@distribution = require 'distributome'
		@msgService = @app_analysis_stats_msgService
		@algorithmService = @app_analysis_stats_algorithms
		@title = "Stats Analysis Module"

		@selectedAlgorithm = "CI for One Mean"

		@loadData()

		# receive updated algorithm from sidebar
		@$scope.$on 'stats:updateAlgorithm', (event, data)=>
			@selectedAlgorithm = data
			console.log("algorithms updated:", @selectedAlgorithm)
			@loadData()
			MathJax.Hub.Queue(["Typeset",MathJax.Hub]);

		#receive data
		@$scope.$on 'stats:onetwoTestdata', (event, data)=>
			@algorithmService.passDataByName(@selectedAlgorithm, data)
			@loadData()

	loadData: () ->
		if (@selectedAlgorithm is "CI for One Mean")
			@CIOMRetrieve()
			return
		else
			return

	update_algo: (evt) ->
		console.log(@selectedAlgorithm)
		@selectedAlgorithm = evt.currentTarget.value
		@msgService.broadcast 'powercalc:updateAlgorithm_back',
			@selectedAlgorithm

	syncData: (dataIn) ->
		@algorithmService.setParamsByName(@selectedAlgorithm, dataIn)
		@loadData()


	# functions for CIOM only
	CIOMRetrieve: () ->
		@params = @algorithmService.getParamsByName(@selectedAlgorithm)
		@CIOMN = @params.n
		@CIOMNMax = @params.nMax
		@CIOMMean = @params.mu
		@CIOMMeanMax = @params.meanMax
		@CIOMStDev = @params.sigma
		@CIOMSigmaMax = @params.sigmaMax
		@CIOMTScore = @params.t
		@CIOMLowerBound = @params.lowBound
		@CIOMUpperBound = @params.upBound
		@CIOMMode = @params.mode
		@CIOMModes = ["Two Tailed", "One Tailed"]
		@CIOMClick()
		return

	CIOMSync: () ->
		@params.n = @CIOMN
		@params.mu = @CIOMMean
		@params.sigma = @CIOMStDev
		@params.mode = @CIOMMode
		@syncData(@params)
		return

	CIOMPress: (evt) ->
		key = evt.which or evt.keyCode
		if key is 13
			@CIOMSync()
		return

	CIOMClick: () ->
		# slider elements
		CIOMNUI = $("#CIOMNUI")
		CIOMMeanUI = $("#CIOMMeanUI")
		CIOMStDevUI= $("#CIOMStDevUI")

		CIOMNUI.slider(
			value: @CIOMN,
			min: 2,
			max: @CIOMNMax,
			range: "min",
			step: 1,
			slide: (event, ui) =>
				@CIOMN = ui.value
				@CIOMSync()
				@$scope.$apply()
		)

		CIOMMeanUI.slider(
			value: @CIOMMean,
			min: 0,
			max: @CIOMMeanMax,
			range: "min",
			step: 0.001,
			slide: (event, ui) =>
				@CIOMMean = ui.value
				@CIOMSync()
				@$scope.$apply()
		)

		CIOMStDevUI.slider(
			value: @CIOMStDev,
			min: 0,
			max: @CIOMSigmaMax,
			range: "min",
			step: 0.001,
			slide: (event, ui) =>
				@CIOMStDev = ui.value
				@CIOMSync()
				@$scope.$apply()
		)


		# enable or disable slider
		CIOMSliders = [CIOMNUI, CIOMMeanUI, CIOMStDevUI]
		if @deployed is true
			for sl in CIOMSliders
				sl.slider("disable")
				sl.find('.ui-slider-handle').hide()
		else
			for sl in CIOMSliders
				sl.slider("enable")
				sl.find('.ui-slider-handle').show()

		return
