'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowerCalcSidebarCtrl extends BaseCtrl
	@inject  'app_analysis_powerCalc_dataService',
	'app_analysis_powerCalc_msgService',
	'app_analysis_powerCalc_algorithms',
	'$scope',
	'$timeout'

	initialize: ->
		console.log("sidebar initialized")
		@dataService = @app_analysis_powerCalc_dataService
		@msgService = @app_analysis_powerCalc_msgService
		@algorithmsService = @app_analysis_powerCalc_algorithms

		# choose algorithms
		@algorithms = ['Select',
		'CI for One Proportion',
		'CI for One Mean',
		'Test of One Proportion',
		'Test of Two Proportions',
		'Pilot Study',
		'R-square (multiple correlation)',
		'Generic chi-square test',
		'Power of a Simple Poisson Test',
		'Two-sample t test (general case)',
		'One-Sample (or Paired) t Test',]
		@powercalcRunning = off
		@algParams = null
		@selectedAlgorithm = @algorithms[3]
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
		@chosenVars = []
		@numericalCols = []
		@categoricalCols = []
		@populations = {}
		@container = {}
		@xCol = null
		@yCol = null
		@Zcol = null
		@labelCol = ["none"]
		@vars = []
		@chosenLabel = null
		@df = null
		@valid = false

		@tTestAlpha = 0.010
		@thresh1 = 0
		@thresh2 = 0

		@onePropThreshMin = 0
		@onePropThreshMax = 1

		@deployed = false
		@precise = false
		@preciseModes = ["larger", "smaller", "equal"]
		@preciseMode = "larger"
		$("#toggle_switch").bootstrapSwitch()
		$("#togglePrecise").bootstrapSwitch()

		# data-driven mode toggle
		$("#toggle_switch").on 'switchChange.bootstrapSwitch', () =>
			@deployed = !@deployed
			@msgService.broadcast 'powercalc:change_mode',
				deploy: @deployed

		#if the switch is toggled, change mode
		$("#togglePrecise").on 'switchChange.bootstrapSwitch', () =>
			@precise = !@precise
			# @msgService.broadcast 'powercalc:change_mode',
			# 	deploy: @deployed

		@slidebar()

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

	loadData: () ->
		@msgService.broadcast 'powercalc:loadData',
			populations:@populations
			chosenCol:@chosenCols
			chosenVar:@chosenVars
			chosenlab:@chosenLabel

		# if data selected meets specified creteria, run the caculation
	run: (data) ->
		if (@selectedAlgorithm is 'Two-sample t test (general case)')
			if @chosenCols.length is 1
				@valid = true
			else
				@valid = false
				@chosenLabel = "none"
				@vars = []
			# if compare two different Variables, calculate sepaerately
			if (@chosenLabel isnt "none") and (@chosenLabel isnt null)
				# check num of chosenCol is one
				if @chosenCols.length isnt 1
					#console.log(@chosenCols.length)
					#window.alert("Must one and only one Col")
					return

				# check num of chosenVar is two
				if @chosenVars.length isnt 2
					#console.log(@chosenVars.length)
					#window.alert("Must two and only two Vars")
					return

				#extract index if col
				index = data.header.indexOf(@chosenCols[0])

				#check if index if -1
				if index is -1
					return

				#extract data from container to population
				@populations = {}
				for elt in @chosenVars
					@populations[elt] = []
					for row in @container[elt]
						@populations[elt].push(row[index])

			else

				# check num of chosenCol is two
				if @chosenCols.length isnt 2
					#console.log(@chosenCols.length)
					#window.alert("Must two and only two Col")
					return

				# extract data from data to population
				index1 = data.header.indexOf(@chosenCols[0])
				index2 = data.header.indexOf(@chosenCols[1])
				@populations = {}
				@populations[@chosenCols[0]] = []
				@populations[@chosenCols[1]] = []
				for row in data.data
					@populations[@chosenCols[0]].push(row[index1])
					@populations[@chosenCols[1]].push(row[index2])

			@msgService.broadcast 'powercalc:onetwoTestdata',
				populations:@populations
				chosenCol:@chosenCols
				chosenVar:@chosenVars
				chosenlab:@chosenLabel
		else if (@selectedAlgorithm is 'One-Sample (or Paired) t Test')
			# if compare two different Variables, calculate separately
			if (@chosenLabel isnt "none") and (@chosenLabel isnt null)

				#extract index if col
				index = data.header.indexOf(@chosenCols)

				#check if index if -1
				if index is -1
					return
				#extract data from container to population
				@populations = {}
				@populations[@chosenVars] = []
				for row in @container[@chosenVars]
					@populations[@chosenVars].push(row[index])

			else
				# extract data from data to population
				index1 = data.header.indexOf(@chosenCols)
				@populations = {}
				@populations[@chosenCols] = []
				for row in data.data
					@populations[@chosenCols].push(row[index1])


			@msgService.broadcast 'powercalc:onetwoTestdata',
				populations:@populations
				chosenCol:@chosenCols
				chosenVar:@chosenVars
				chosenlab:@chosenLabel
		else if (@selectedAlgorithm is 'Test of One Proportion')
			if @chosenCols is null
				return

			#extract index if col
			index = data.header.indexOf(@chosenCols)
			#check if index if -1
			if index is -1
				return

			size = 0
			# check if valid category
			if (@chosenLabel is "none") or (@chosenLabel is null)
				if @precise then size = @runPrecise(data.data, index, 0, false)[0]
				else size = data.data.length
			else 
				if @precise then size = @runPrecise(@container[@chosenVars], index, 0, false)[0]
				else size = @container[@chosenVars].length

			#calculate
			totalSize = data.data.length
			if size is 0
				size = 1
			proportion = size/totalSize

			@msgService.broadcast 'powercalc:onePropdata',
				prop:proportion
				size:size
				chosenCol:@chosenCols
				chosenVar:@chosenVars
				chosenlab:@chosenLabel




	runPrecise: (data, index1, index2, isTwoProp) ->
		if not isTwoProp
			temp = []
			switch @preciseMode
				when "larger"
					for x in data
						if x[index1] > @thresh1
							temp.push(x)
				when "smaller"
					for x in data
						console.log x[index1] < @thresh1
						if x[index1] < @thresh1
							temp.push(x)
				when "equal"
					for x in data
						if x[index1] is @thresh1
							temp.push(x)
			return [temp.length]
		else 
			#TODO
			return [0, 0]


	updateAlgControls: () ->
		#update algorithm method in local and broadcast to main control
		#broadcast algorithms to main controller
		@msgService.broadcast 'powercalc:updateAlgorithm',
			@selectedAlgorithm


	# called when you update your category
	updateVar: (data) ->
		index = data.header.indexOf(@chosenLabel)
		@vars = []
		@container = []
		if index isnt -1
			for row in data.data
				if row[index] not of @container
					@container[row[index]] = []

				if row[index] not in @vars
					@vars.push(row[index])

				@container[row[index]].push(row)

	uniqueVals: (arr) -> arr.filter (x, i, a) -> i is a.indexOf x

	parseData: (data) ->
		@df = data
		@dataService.inferDataTypes data, (resp) =>
			if resp? and resp.dataFrame? and resp.dataFrame.data?

				#update data types
				for type, idx in @df.types
					@df.types[idx] = resp.dataFrame.data[idx]

				# update columns
				@categoricalCols = []
				@labelCol = ["none"]
				id = 0
				for header in @df.types
					if header in ["number", "integer"]
						@categoricalCols.push(@df.header[id])
					else if header in ["string"]
						@labelCol.push(@df.header[id])
					id += 1
			# @updateDataPoints(@df)

			# @msgService.broadcast 'powercalc:updateDataPoints',
			# 	dataPoints: @df

	slidebar: () ->
		$("#tTestAlphaUI").slider(
			min: 0.001
			max: 0.200
			value: @tTestAlpha
			orientation: "horizontal"
			range: "min"
			step: 0.001
			slide: (event, ui) =>
				@tTestAlpha = ui.value
				@msgService.broadcast 'powercalc:alpha',
					alpha_in: @tTestAlpha
		)

		$("#onePropThresh").slider(


		)

	changeValue: (evt) ->
		name = evt.target.name
		key = evt.which or evt.keyCode
		if key is 13
			@slidebar()
		return

	precisePress: (evt) ->
		key = evt.which or evt.keyCode
		if key is 13
			@run(@df)
		return
