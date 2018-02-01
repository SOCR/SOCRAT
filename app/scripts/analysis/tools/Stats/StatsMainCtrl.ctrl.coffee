'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class StatsMainCtrl extends BaseCtrl
	@inject 'app_analysis_stats_msgService',
	'app_analysis_stats_algorithms',
	'$timeout',
	'$scope'

	initialize: ->

		# required basic modules
		@d3 = require 'd3'
		@ve = require 'vega-embed'
		@distribution = require 'distributome'
		@msgService = @app_analysis_stats_msgService
		@algorithmService = @app_analysis_stats_algorithms
		@title = "Stats Analysis Module"

		@selectedAlgorithm = "CI for One Mean"

		@loadData()


		@$scope.$on 'stats:alpha', (event, data)=>
			@algorithmService.passAlphaByName(@selectedAlgorithm, data)
			@loadData()

		# receive updated algorithm from sidebar area
		@$scope.$on 'stats:updateAlgorithm', (event, data)=>
			@selectedAlgorithm = data
			console.log("algorithms updated:", @selectedAlgorithm)
			@loadData()
			MathJax.Hub.Queue(["Typeset",MathJax.Hub]);

		# receive data
		@$scope.$on 'stats:Data', (event, data)=>
			@algorithmService.passDataByName(@selectedAlgorithm, data)
			@loadData()


	# load data to a specified calculator
	loadData: () ->
		if (@selectedAlgorithm is "CI for One Mean")
			@CIOMRetrieve()
		else if (@selectedAlgorithm is "CI for One Proportion") then @CIOPRetrieve()

	# outdated
	update_algo: (evt) ->
		console.log(@selectedAlgorithm)
		@selectedAlgorithm = evt.currentTarget.value
		@msgService.broadcast 'powercalc:updateAlgorithm_back',
			@selectedAlgorithm

	# call to update data parameters of specified calculator
	syncData: (dataIn) ->
		@algorithmService.setParamsByName(@selectedAlgorithm, dataIn)
		@loadData()


	# functions for CIOM only
	# retrieve data parameters from specified calculators
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
		@CIOMTest()
		return


	CIOMTest: () ->

		resultData = [{"yield":27,"variety":"Manchuria","year":1931,"site":"University Farm"},
		{"yield":48.86667,"variety":"Manchuria","year":1931,"site":"Waseca"},
		{"yield":27.43334,"variety":"Manchuria","year":1931,"site":"Morris"},
		{"yield":39.93333,"variety":"Manchuria","year":1931,"site":"Crookston"},
		{"yield":32.96667,"variety":"Manchuria","year":1931,"site":"Grand Rapids"},
		{"yield":28.96667,"variety":"Manchuria","year":1931,"site":"Duluth"},
		{"yield":43.06666,"variety":"Glabron","year":1931,"site":"University Farm"},
		{"yield":55.2,"variety":"Glabron","year":1931,"site":"Waseca"},
		{"yield":28.76667,"variety":"Glabron","year":1931,"site":"Morris"}]

		console.log("indsideeeeeeeeeeeeeeeeeeee test")
		console.log(resultData)

		vlSpec =
			{
				"$schema": "https://vega.github.io/schema/vega-lite/v2.json",
				"data": {"values": resultData},
				"layer": [{
					"mark": {"type": "point", "filled": true},
					"encoding": {
						"x": {
							"aggregate": "mean", "field": "yield", "type": "quantitative",
							"scale": {"zero": false},
							"axis": {"title": "Barley Yield"}
						},
						"y": {
							"field": "variety", "type": "ordinal"
						},
						"color": {"value": "black"}
					}
				}, {
				"mark": "rule",
				"encoding": {
					"x": {
						"aggregate": "ci0", "field": "yield", "type": "quantitative",
						"scale": {"zero": false}
					},
					"x2": {
						"aggregate": "ci1", "field": "yield", "type": "quantitative"
					},
					"y": {
						"field": "variety", "type": "ordinal"
					}
				}
				}]
			}
		# vegaEmbed("#vis", vlSpec)
		opt = {"actions": {export: true, source: false, editor: false}}
		@ve '#vis', vlSpec, opt, (error, result) ->
		 	return

	# call syncData
	CIOMSync: () ->
		@params.n = @CIOMN
		@params.mu = @CIOMMean
		@params.sigma = @CIOMStDev
		@params.mode = @CIOMMode
		@syncData(@params)
		return

	# if user press enter, then sync data parameters
	# otherwise, do nothing
	CIOMPress: (evt) ->
		key = evt.which or evt.keyCode
		if key is 13
			@CIOMSync()
		return

	# update all sliders
	# and check deployment of data mode
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

	# functions for CIOM only
	CIOPRetrieve:() ->
		@params = @algorithmService.getParamsByName(@selectedAlgorithm)
		@CIOPP = @params.p
		@CIOPN = @params.n
		@CIOPT = @params.t
		@CIOPTMax = @params.tMax
		@zscore = @params.z
		@upbound = @params.u
		@lowbound = @params.l
		@confinterval =@params.ci
		@ciAlpha =  @params.a
		@standarddev = @params.sd
		@cilevel = 1.0 - @ciAlpha
		@CIOPClick()

	CIOPSync: () ->
		@params.p = @CIOPP
		@params.n = @CIOPN
		@params.t = @CIOPT
		@syncData(@params)

	CIOPPress: (evt) ->
		key = evt.which or evt.keyCode
		if key is 13
			@CIOMSync()
		return

	CIOPClick: () ->
		#slider elements
		CIOPNUI = $("#CIOPNUI")
		CIOPTUI = $("#CIOPTUI")
		sliders = [CIOPNUI, CIOPTUI]

		CIOPNUI.slider(
			value: @CIOPN,
			min: 0,
			max: @CIOPTMax,
			range: 'min',
			step: 1,
			slide: (event, ui) =>
				@CIOPN = ui.value
				@CIOPSync()
				@$scope.$apply()
		)

		CIOPTUI.slider(
			value: @CIOPT,
			min: 0,
			max: @CIOPTMax,
			range: 'min',
			step: 1,
			slide: (event, ui) =>
				@CIOPT = ui.value
				@CIOPSync()
				@$scope.$apply()
		)

		if @deployed is true
			for sl in sliders
				sl.slider("disable")
				sl.find('.ui-slider-handle').hide()
		else
			for sl in sliders
				sl.slider("enable")
				sl.find('.ui-slider-handle').show()
		return
