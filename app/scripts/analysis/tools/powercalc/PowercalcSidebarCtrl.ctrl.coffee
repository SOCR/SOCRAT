'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcSidebarCtrl extends BaseCtrl
	@inject 'app_analysis_powercalc_msgService', 'app_analysis_powercalc_algorithms', '$scope', '$timeout'

	initialize: ->
		console.log("sidebar initialized")
		@msgService = @app_analysis_powercalc_msgService
		@algorithmsService = @app_analysis_powercalc_algorithms


		@algorithms = ['Select', 'CI for One Proportion', 'CI for One Mean', 'Test of One Proportion', 'One-Sample (or Paired) t Test', 'Pilot Study', 'R-square (multiple correlation)', 'Generic chi-square test']
		@powercalcRunning = off
		@algParams = null
		@selectedAlgorithm = @algorithms[0]

		# var needed for cfap
		@is_cfap = off
		@is_finite_population = off
		@is_worst_case = off
		@cfap_N = null
		@cfap_pi = null
		
		@$scope.$on 'powercalc:updateAlgorithm_back', (event, data)=>
      		@selectedAlgorithm = data


	updateAlgControls: () ->
		#update algorithm method in local and broadcast to main control
		#broadcast algorithms to main controller
		@msgService.broadcast 'powercalc:updateAlgorithm',
			@selectedAlgorithm


	help: () ->
		#console.log("Hit")
		#get help message from corresponding interface
		@algorithmsService.get_cfap_help()
