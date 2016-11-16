'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcSidebarCtrl extends BaseCtrl
	@inject 'app_analysis_powercalc_allService',
		'app_analysis_powercalc_msgService'
		'app_analysis_powercalc_algorithms'
		'$scope'
		'$timeout'

	initialize: ->
		@dataService = @app_analysis_powercalc_allService
		@msgService = @app_analysis_powercalc_msgService
		@algorithmsService = @app_analysis_powercalc_algorithms
		@algorithms = @algorithmsService.getNames()
		@DATA_TYPES = @dataService.getDataTypes()
		# set up data and algorithm-agnostic controls
		@powercalcRunning = off
		@algParams = null

		# choose first algorithm as default one
		if @algorithms.length > 0
			@selectedAlgorithm @algorithms[0]
			#@updateAlgControls()


	updateAlgControls: () ->
		algParams = @algorithmsService.getParamsByName @selectedAlgorithm