'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcSidebarCtrl extends BaseCtrl
	@inject  'app_analysis_statistic_dataService', 'app_analysis_statistic_msgService', '$scope', '$timeout'

	initialize: ->
		@dataService = @app_analysis_statistic_dataService
		@msgService = @app_analysis_statistic_msgService
		
		# choose algorithms
		@algorithms = [ 
		 'One-Sample (or Paired) t Test',  
		 'Two-sample t test (general case)']
		@algParams = null
		@selectedAlgorithm = @algorithms[0]
		@DATA_TYPES = @dataService.getDataTypes()
