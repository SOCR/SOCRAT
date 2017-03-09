'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcSidebarCtrl extends BaseCtrl
	@inject  'app_analysis_powercalc_dataService', 'app_analysis_powercalc_msgService', 'app_analysis_powercalc_algorithms', '$scope', '$timeout'

	initialize: ->
		console.log("sidebar initialized")
		@dataService = @app_analysis_powercalc_dataService
		@msgService = @app_analysis_powercalc_msgService
		@algorithmsService = @app_analysis_powercalc_algorithms

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
		@selectedAlgorithm = @algorithms[0]
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
		@xCol = null
		@yCol = null
		@labelCol = null


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



	updateAlgControls: () ->
		#update algorithm method in local and broadcast to main control
		#broadcast algorithms to main controller
		@msgService.broadcast 'powercalc:updateAlgorithm',
			@selectedAlgorithm

			# update data-driven sidebar controls
	updateSidebarControls: (data) ->
		@cols = data.header
		@numericalCols = (col for col, idx in @cols when data.types[idx] in ['integer', 'number'])
		@categoricalCols = (col for col, idx in @cols when data.types[idx] in ['string', 'integer'])
		# make sure number of unique labels is less than maximum number of clusters for visualization
		if @algParams.k
			[minK, ..., maxK] = @algParams.k
			colData = d3.transpose(data.data)
			@categoricalCols = @categoricalCols.filter (x, i) =>
				@uniqueVals(colData[@cols.indexOf(x)]).length < maxK
		[@xCol, @yCol, ..., lastCol] = @numericalCols
		#@clusterRunning = off
		if @labelCol
			@uniqueLabels =
				num: @uniqueVals (data.header.indexOf(@labelCol) for row in data.data)
				labelCol: @labelCol
		@$timeout =>
			@updateDataPoints data

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
				@updateSidebarControls(resp.dataFrame)
				@updateDataPoints(resp.dataFrame)
				#@ready = on

	help: () ->
		#console.log("Hit")
		#get help message from corresponding interface
		@algorithmsService.get_cfap_help()
