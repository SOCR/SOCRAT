'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcSidebarCtrl extends BaseCtrl
	@inject  'app_analysis_powercalc_dataService', 
	'app_analysis_powercalc_msgService', 
	'app_analysis_powercalc_algorithms', 
	'app_analysis_powercalc_TwoTGUI',
	'$scope', 
	'$timeout'

	initialize: ->
		console.log("sidebar initialized")
		@dataService = @app_analysis_powercalc_dataService
		@msgService = @app_analysis_powercalc_msgService
		@algorithmsService = @app_analysis_powercalc_algorithms
		@TwoTGUI = @app_analysis_powercalc_TwoTGUI

		# choose algorithms
		@algorithms = ['Select',
		 'CI for One Proportion', 
		 'CI for One Mean', 
		 'Test of One Proportion', 
		 'One-Sample (or Paired) t Test', 
		 'Pilot Study', 
		 'R-square (multiple correlation)', 
		 'Generic chi-square test', 
		 'Power of a Simple Poisson Test', 
		 'Two-sample t test (general case)']
		@powercalcRunning = off
		@algParams = null
		@selectedAlgorithm = @algorithms[9]
		@DATA_TYPES = @dataService.getDataTypes()

		# set up data and algorithm-agnostic controls
		@useLabels = off
		@reportAccuracy = on
		@clusterRunning = off
		@ready = off
		@running = 'hidden'
		@uniqueLabels =
		  labelCol: null
		  num: null
		@algParams = null

		# dataset
		@dataFrame = null
		@dataType = null
		@cols = []
		@chosenCols = []
		@numericalCols = []
		@categoricalCols = []
		@populations = {}
		@xCol = null
		@yCol = null
		@Zcol = null
		@labelCol = null

		@TwoTGUI_alpha=0.010
		@deployed = false
		$("#toggle_switch").bootstrapSwitch();

		$("#toggle_switch").on 'switchChange.bootstrapSwitch', () =>
			@deployed = !@deployed
			@change_mode()

		@prepare()


		@dataService.getData().then (obj) =>
			if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
				if @dataType isnt obj.dataFrame.dataType
					# update local data type
					@dataType = obj.dataFrame.dataType
					# send update to main are actrl
					@msgService.broadcast 'powercalc:updateDataType', obj.dataFrame.dataType
				# make local copy of data
				@dataFrame = obj.dataFrame
				# parse dataFrame
				@parseData obj.dataFrame
			else
				# TODO: add processing for nested object
				console.log 'NESTED DATASET'

		@$scope.$on 'powercalc:updateAlgorithm_back', (event, data)=>
			@selectedAlgorithm = data
			console.log("algorithms updated:", @selectedAlgorithm)


	drive_data: () ->
		@msgService.broadcast 'powercalc:drive_data',
			populations:@populations
			chosen:@chosenCols

	change_mode: () -> 
		#console.log "mode changed"
		@msgService.broadcast 'powercalc:change_mode',
			deploy: @deployed


	updateAlgControls: () ->
		#update algorithm method in local and broadcast to main control
		#broadcast algorithms to main controller
		@msgService.broadcast 'powercalc:updateAlgorithm',
			@selectedAlgorithm


	calculateN: (data) ->
		@populations = {}
		for col in @chosenCols
			sum = 0
			index = data.header.indexOf(col)
			if !(index is -1)
				loc_data = []
				for row in data.data
					loc_data.push(parseFloat(row[index]))
					if @populations[col] is undefined
						sum = sum + parseFloat(row[index])
						@populations[col] = {"counter":0, "mean":0, "sigma":0}
						@populations[col]["counter"] = 1
					else 
						sum = sum + parseFloat(row[index])
						@populations[col]["counter"] = @populations[col]["counter"] + 1
			mean = sum / @populations[col]["counter"]
			@populations[col]["sum"] = sum
			@populations[col]["mean"] = mean
			@populations[col]["data"] = loc_data
			@calculate_sigma(data, col, index)
		console.log(@populations)
		@drive_data()

	calculate_sigma: (data, col, index) ->
		sum = 0
		for row in data.data
			sum = sum + Math.pow(parseFloat(row[index]) - @populations[col]["mean"], 2)
		@populations[col]["variance"] = sum / @populations[col]["counter"]
		@populations[col]["sigma"] = Math.sqrt(sum / @populations[col]["counter"])
		return 

	updateDataPoints: (data=null, means=null, labels=null) ->
		if data
			if @labelCol
				@uniqueLabels =
					num: @uniqueVals (data.header.indexOf(@labelCol) for row in data.data)
					labelCol: @labelCol
			xCol = data.header.indexOf @xCol
			yCol = data.header.indexOf @yCol
			data = ([row[xCol], row[yCol]] for row in data.data)
		@msgService.broadcast 'powercalc:updateDataPoints',
			dataPoints: data
			means: means
			labels: labels

	uniqueVals: (arr) -> arr.filter (x, i, a) -> i is a.indexOf x

	parseData: (data) ->
		@dataService.inferDataTypes data, (resp) =>
			if resp and resp.dataFrame
				# update columns
				@categoricalCols = []
				id = 0
				for header in resp.dataFrame.types
					if header is "number"
						@categoricalCols.push(resp.dataFrame.header[id])
					id += 1
				@updateDataPoints(resp.dataFrame)
			@msgService.broadcast 'powercalc:updateDataPoints',
				dataPoints: resp.dataFrame

	prepare: () ->
		$("#alphauii").slider(
			min: 0.001
			max: 0.200
			value: @TwoTGUI_alpha
			orientation: "horizontal"
			range: "min"
			step: 0.001
			slide: (event, ui) =>
				@TwoTGUI_alpha = ui.value
				$('#alphai').val ui.value
				@msgService.broadcast 'powercalc:alpha',
					alpha_in: @TwoTGUI_alpha
				return
				# @TwoTGUI_update()
				# if @deployed
				#   @TwoTGUI_graph()
				# return
		)
		$("#alphai").val($("#alphauii").slider("value"));
