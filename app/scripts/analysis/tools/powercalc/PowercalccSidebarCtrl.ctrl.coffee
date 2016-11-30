'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcSidebarCtrl extends BaseCtrl
	@inject 'app_analysis_powercalc_msgService',
		'app_analysis_powercalc_algorithms'
		'$scope'
		'$timeout'

	initialize: ->
    @dataService = @app_analysis_powercalc_dataService
	  @msgService = @app_analysis_powercalc_msgService
	  @algorithmsService = @app_analysis_powercalc_algorithms
	  @DATA_TYPES = @dataService.getDataTypes()
	  @selectedAlgorithm = @algorithms[0]

		# set up data and algorithm-agnostic controls
    @algorithms = @algorithmsService.getNames()
	  @powercalcRunning = off
		@algParams = null

		#var needed for cfap
    @is_cfap = off
		@is_finite_population = off
		@is_worst_case = off
		@cfap_N = null
		@cfap_pi = null



	updateAlgControls: () ->
		#update algorithm method in local and broadcast to main control
		if selectedAlgorithm is algorithms[0]
			is_cfap = on
		@msgService.broadcast 'powercalc:updateAlgorithm',
			@is_cfap


	help: () ->
		#get help message from corresponding interfaces
		if is_cfap
			algorithmsService.get_cfap_help()
