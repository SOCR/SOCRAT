'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcSidebarCtrl extends BaseCtrl
	@inject 'app_analysis_powercalc_msgService', 'app_analysis_powercalc_algorithms', '$scope', '$timeout'

	initialize: ->
		console.log("sidebar initialized")
		@msgService = @app_analysis_powercalc_msgService
		@algorithmsService = @app_analysis_powercalc_algorithms


		@algorithms = ['Select', 'CI for One Proportion', 'other']
		@powercalcRunning = off
		@algParams = null
		@selectedAlgorithm = @algorithms[0]

		# var needed for cfap
		@is_cfap = off
		@is_finite_population = off
		@is_worst_case = off
		@cfap_N = null
		@cfap_pi = null
		#console.log("algorithms initialized, is_cfap:",@is_cfap)



	updateAlgControls: () ->
		#update algorithm method in local and broadcast to main control
		if @selectedAlgorithm is @algorithms[1]
			@is_cfap = on
		else
			@is_cfap = false;
		#broadcast algorithms to main controller
		@msgService.broadcast 'powercalc:updateAlgorithm',
			@selectedAlgorithm
		console.log("algorithms updated, cfap:", @is_cfap)


	help: () ->
		#console.log("Hit")
		#get help message from corresponding interface
		@algorithmsService.get_cfap_help()
