'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcSidebarCtrl extends BaseCtrl
	@inject 'app_analysis_powercalc_dataService',
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
		@selectedAlgorithm = @algorithms[0]
		@is_cfap = off
		# set up data and algorithm-agnostic controls
		@powercalcRunning = off
		@algParams = null

		#var needed for cfap
		@is_finite_population = off
		@is_worst_case = off
		@cfap_N = null
		@cfap_pi = null



	updateAlgControls: () ->
		if selectedAlgorithm is algorithms[0]
			is_cfap = on


