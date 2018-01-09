'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class StatsSidebarCtrl extends BaseCtrl
	@inject  'app_analysis_stats_dataService',
	'app_analysis_stats_msgService',
	'app_analysis_stats_algorithms',
	'$scope',
	'$timeout'

	initialize: ->
		# initialing all modules
		@dataService = @app_analysis_stats_dataService
		@msgService = @app_analysis_stats_msgService
		@algorithmsService = @app_analysis_stats_algorithms

		# all alglorithms
		@algorithms = ['Select',
		'CI for One Mean'
		]
		# select first calculator
		@selectedAlgorithm = @algorithms[1]

		# set up data and algorithm-agnostic controls
		@DATA_TYPES = @dataService.getDataTypes()
		@dataFrame = null
		@dataType = null
		@numericalCols = []
		@categoricalCols = []
		@subCategoricalCols = []
		@labelCol = ["none"]
		@df = null

		# sidebar variables needed to process data
		@newTarget = true
		@curTarget = ["",""]
		@chosenColsOne = null
		@chosenColsTwo = []
		@chosenCats = null
		@chosenSubCatsOne = []
		@chosenSubCatsTwo = []
		@alpha = 0.01
		@thresh = 0

		# pre-processed data container
		@container = {} # {name1:[#,#,#,#,#,#....], name2:[#,#,#,#,#,#,#,#.....]}
		@MinMax = [{"min": 0, "max": 1}, {"min": 0, "max": 1}]
		@populations = {}


		$("#toggleDataDriven").bootstrapSwitch()
		$("#toggleThresh").bootstrapSwitch()
		$("#twoPropToggleThresh").bootstrapSwitch()
		# data-driven mode toggle
		$("#toggleDataDriven").on 'switchChange.bootstrapSwitch', () =>
			@deployed = !@deployed
			@msgService.broadcast 'stats:changeMode',
				deploy: @deployed
		# thresh mode toggle
		$("#toggleThresh").on 'switchChange.bootstrapSwitch', () =>
			@threshMode = !@threshMode
		$("#twoPropToggleThresh").on 'switchChange.bootstrapSwitch', () =>
			@threshMode = !@threshMode


		# initialize slider
		@slider()

		# receive raw data
		@dataService.getData().then (obj) =>
			if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
				if @dataType isnt obj.dataFrame.dataType
					# update local data type
					@dataType = obj.dataFrame.dataType
					# send update to main are actrl
					@msgService.broadcast 'stats:updateDataType', obj.dataFrame.dataType
				# make local copy of data
				@dataFrame = obj.dataFrame
				# parse dataFrame
				@df = obj.dataFrame
				@parseData obj.dataFrame
			else
				# TODO: add processing for nested object
				console.log 'NESTED DATASET'

		# receive updated algorithm broadcasted from mainArea
		@$scope.$on 'stats:updateAlgorithmBack', (event, data)=>
			@selectedAlgorithm = data

	# Once the algorithm is updated, braodcast to mainArea
	updateAlgControls: () ->
		#broadcast algorithms to main controller
		@msgService.broadcast 'stats:updateAlgorithm',
			@selectedAlgorithm

	# called right after receiving the raw data
	# categorize data types into numeric or names
	# No need to modify this method unless permitted
	parseData: () ->
		@dataService.inferDataTypes @df, (resp) =>
			if resp? and resp.dataFrame? and resp.dataFrame.data?

				#update data types
				for type, idx in @df.types
					@df.types[idx] = resp.dataFrame.data[idx]

				# if the column is numeric, append the header name to @numericalCols
				# if the column is string, append the header name to @categoricalCols
				@numericalCols = []
				@categoricalCols = ["none"]
				id = 0
				for header in @df.types
					if header in ["number", "integer"]
						@numericalCols.push(@df.header[id])
					else if header in ["string"]
						@categoricalCols.push(@df.header[id])
					id += 1

	# called when sidebar updates variables
	# 1. update categories and its subcategories
	# 2. push all the related data into its own category
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

	# call specified pre-processor
	run: () ->
		if (@selectedAlgorithm is 'CI for One Mean')
			@CIOM()
		return


	###
		pre-process data when the specified calculator is CIOM
		@return: TODO
	###
	CIOM: () ->
		@populations = {}

		# if compare two different Variables, calculate separately
		if (@chosenCats isnt "none") and (@chosenCats isnt undefined)

			#extract index if col
			index = @df.header.indexOf(@chosenColsOne)

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

		@msgService.broadcast 'stats:CIOMdata',
			popl: @populations

	# collection of sliders that update sliders
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
				@msgService.broadcast 'stats:alpha',
					@alpha
				@$scope.$apply()
		)