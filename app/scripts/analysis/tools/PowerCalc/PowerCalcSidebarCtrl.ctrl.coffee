'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowerCalcSidebarCtrl extends BaseCtrl
	@inject  'app_analysis_powerCalc_dataService',
	'app_analysis_powerCalc_msgService',
	'app_analysis_powerCalc_algorithms',
	'$scope',
	'$timeout'

	initialize: ->
		@dataService = @app_analysis_powerCalc_dataService
		@msgService = @app_analysis_powerCalc_msgService
		@algorithmsService = @app_analysis_powerCalc_algorithms

		# all alglorithms
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
		@selectedAlgorithm = @algorithms[3]

		# set up data and algorithm-agnostic controls
		@DATA_TYPES = @dataService.getDataTypes()

		# data
		@dataFrame = null
		@dataType = null
		@numericalCols = []
		@categoricalCols = []
		@subCategoricalCols = []
		@labelCol = ["none"]
		@df = null

		# running conditions
		@newTarget = true
		@curTarget = ["",""]

		# pre-processed data container
		@container = {} # {a:[], b:[]}
		@MinMax = [{"min": 0, "max": 1}, {"min": 0, "max": 1}]
		@populations = {}

		# sidebar variables
		@chosenColsOne = null
		@chosenColsTwo = []
		@chosenCats = null
		@chosenSubCatsOne = []
		@chosenSubCatsTwo = []
		@alpha = 0.01
		@thresh = 0
		@thresh1 = 0
		@thresh2 = 0

		# mode
		@deployed = false
		@threshMode = false
		@threshTypeModes = ["larger", "smaller", "equal"]
		@threshTypeMode = "larger"
		$("#toggleDataDriven").bootstrapSwitch()
		$("#toggleThresh").bootstrapSwitch()
		# data-driven mode toggle
		$("#toggleDataDriven").on 'switchChange.bootstrapSwitch', () =>
			@deployed = !@deployed
			@msgService.broadcast 'powercalc:change_mode',
				deploy: @deployed
		# thresh mode toggle
		$("#toggleThresh").on 'switchChange.bootstrapSwitch', () =>
			@threshMode = !@threshMode

		# initialize slider
		@slider()

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
				@df = obj.dataFrame
				@parseData obj.dataFrame
			else
				# TODO: add processing for nested object
				console.log 'NESTED DATASET'

		@$scope.$on 'powercalc:updateAlgorithm_back', (event, data)=>
			@selectedAlgorithm = data

	updateAlgControls: () ->
		#broadcast algorithms to main controller
		@msgService.broadcast 'powercalc:updateAlgorithm',
			@selectedAlgorithm

	parseData: () ->
		@dataService.inferDataTypes @df, (resp) =>
			if resp? and resp.dataFrame? and resp.dataFrame.data?

				#update data types
				for type, idx in @df.types
					@df.types[idx] = resp.dataFrame.data[idx]

				# update columns
				@numericalCols = []
				@categoricalCols = ["none"]
				id = 0
				for header in @df.types
					if header in ["number", "integer"]
						@numericalCols.push(@df.header[id])
					else if header in ["string"]
						@categoricalCols.push(@df.header[id])
					id += 1

	# called when update category
	update: () ->
		index = @df.header.indexOf(@chosenCats)
		@container = {}
		@subCategoricalCols = []
		for row in @df.data
			if row[index] not of @container
				@container[row[index]] = []

			if row[index] not in @subCategoricalCols
				@subCategoricalCols.push(row[index])

			@container[row[index]].push(row)

	run: () ->
		if (@selectedAlgorithm is 'Two-sample t test (general case)')
			@populations = {}
			if @chosenColsTwo.length is 1
				$("#twoTestCat").prop("disabled", false)
				$("#twoTestSubCat").prop("disabled", false)
			else
				$("#twoTestCat").prop("disabled", true)
				$("#twoTestSubCat").prop("disabled", true)
				@chosenCats = "none"
				@subCategoricalCols = []

			# compare two different Variables, calculate sepaerately
			if (@chosenCats isnt "none") and (@chosenCats isnt undefined)
				# check num of chosenCol is one
				if @chosenColsTwo.length isnt 1
					return
				# check num of chosenSubCats is two
				if @chosenSubCatsTwo.length isnt 2
					return

				# update comparison targets
				if not @equalList(@curTarget, @chosenSubCatsTwo)
					@curTarget = @chosenSubCatsTwo
					@newTarget = true

				#extract index if col
				index = @df.header.indexOf(@chosenColsTwo[0])

				#extract data from container to population
				for elt in @chosenSubCatsTwo
					@populations[elt] = []
					for row in @container[elt]
						@populations[elt].push(row[index])

			else

				if @chosenColsTwo.length isnt 2
					return

				# update comparison targets
				if not @equalList(@curTarget, @chosenColsTwo)
					@curTarget = @chosenColsTwo
					@newTarget = true

				# extract data from data to population
				index1 = @df.header.indexOf(@chosenColsTwo[0])
				index2 = @df.header.indexOf(@chosenColsTwo[1])
				@populations[@chosenColsTwo[0]] = []
				@populations[@chosenColsTwo[1]] = []
				for row in @df.data
					@populations[@chosenColsTwo[0]].push(row[index1])
					@populations[@chosenColsTwo[1]].push(row[index2])

			@msgService.broadcast 'powercalc:onetwoTestdata',
				popl: @populations
				target: @curTarget


		else if (@selectedAlgorithm is 'One-Sample (or Paired) t Test')
			@populations = {}
			# if compare two different Variables, calculate separately
			if (@chosenCats isnt "none") and (@chosenCats isnt undefined)

				#extract index if col
				index = @df.header.indexOf(@chosenColsOne)

				if not @equalList(@curTarget, [@chosenSubCatsOne])
					@curTarget = @chosenSubCatsOne
					@newTarget = true

				#extract data from container to population
				@populations[@chosenSubCatsOne] = []
				for row in @container[@chosenSubCatsOne]
					@populations[@chosenSubCatsOne].push(row[index])

			else
				# extract data from data to population
				index1 = @df.header.indexOf(@chosenColsOne)
				@populations[@chosenColsOne] = []
				for row in @df.data
					@populations[@chosenColsOne].push(row[index1])


			@msgService.broadcast 'powercalc:onetwoTestdata',
				popl: @populations
				target: @curTarget

		else if (@selectedAlgorithm is 'Test of One Proportion')
			if @chosenCols is null
				return

			#extract index if col
			index = @df.header.indexOf(@chosenColsOne)
			size = 0

			# calculate size
			if (@chosenCats is "none") or (@chosenCats is undefined)
				# update comparison target
				if not @equalList(@curTarget, [@chosenColsOne])
					@curTarget = @chosenColsOne
					@newTarget = true

				@findMinMax(@df.data, index, -1, false)

				if @threshMode then size = @runThresh(@df.data, index, -1, false)[0]
				else size = @df.data.length

			else 
				# update comparison target
				if not @equalList(@curTarget, [@chosenSubCatsOne])
					@curTarget = @chosenSubCatsOne
					@newTarget = true

				if @threshMode then size = @runThresh(@container[@chosenSubCatsOne], index, 0, false)[0]
				else size = @container[@chosenSubCatsOne].length

			#calculate
			totalSize = @df.data.length
			if size is 0 then size = 1
			proportion = size/totalSize

			@msgService.broadcast 'powercalc:onePropdata',
				prop: proportion
				size: size
				target: @curTarget

		# else if (@selectedAlgorithm is 'Test of Two Proportions')
		# 	if @chosenCols is null
		# 		return

		# 	#extract index if col
		# 	index = data.header.indexOf(@chosenCols)
		# 	#check if index if -1
		# 	if index is -1
		# 		return

		# 	if (@chosenLabel is "none") or (@chosenLabel is null)
		# 		return

		# 	if (@chosenVars.length isnt 2)
		# 		return

		# 	size1 = @container[@chosenVars[0]].length
		# 	size2 = @container[@chosenVars[1]].length
		# 	totalSize = data.data.length
		# 	prop1 = size1/totalSize
		# 	prop2 = size2/totalSize

		# 	@msgService.broadcast 'powercalc:twoPropdata',
		# 		prop1:prop1
		# 		prop2:prop2
		# 		n1:size1
		# 		n2:size2
		# 		chosenCol:@chosenCols
		# 		chosenVar:@chosenVars
		# 		chosenlab:@chosenLabel

	findMinMax: (data, index1, index2, isTwo) ->
		if @newTarget
			@newTarget = false
			@MinMax = [
				{"min": Number.MAX_SAFE_INTEGER, "max": Number.MIN_SAFE_INTEGER}, 
				{"min": Number.MAX_SAFE_INTEGER, "max": Number.MIN_SAFE_INTEGER}
			]
			if isTwo
				# TODO
				return
			else 
				for row in data
					i = parseFloat(row[index1])
					if i < @MinMax[0]["min"]
						@MinMax[0]["min"] = i
					if i > @MinMax[0]["max"]
						@MinMax[0]["max"] = i
		@slider()


	runThresh: (data, index1, index2, isTwo) ->
		if isTwo
			# TODO
			return [0,0]
		else
			temp = 0
			switch @threshTypeMode
				when "larger"
					for x in data
						if parseFloat(x[index1]) > @thresh
							temp += 1
				when "smaller"
					for x in data
						if parseFloat(x[index1]) < @thresh
							temp += 1
				when "equal"
					for x in data
						if parseFloat(x[index1]) is @thresh
							temp += 1
			return [temp]

	slider: ->
		$("#alphaUI").slider(
			min: 0.001
			max: 0.200
			value: @alpha
			orientation: "horizontal"
			range: "min"
			step: 0.001
			slide: (event, ui) =>
				@alpha = ui.value
				@msgService.broadcast 'powercalc:alpha',
					alpha_in: @alpha
		)
		$("#onePropThreshUI").slider(
			min: @MinMax[0]["min"]
			max: @MinMax[0]["max"]
			value: @thresh1
			orientation: "horizontal"
			range: "min"
			step: 0.1
			slide: (event, ui) =>
				@thresh = ui.value
				@run()
				return
		)

	changeValue: (evt) ->
		name = evt.target.name
		key = evt.which or evt.keyCode
		if key is 13
			@slider()
			@run()
		return

	# compare if list a is same as list b
	# return false when not equal
	equalList: (a, b) ->
		if (a.length isnt b.length) then return false
		i = 0
		for item in a
			if b[0] isnt item then return false
			i+=1
		return true











