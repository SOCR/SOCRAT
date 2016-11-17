'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcMainCtrl extends BaseCtrl
	@inject 'app_analysis_powercalc_allServic', '$timeout', 'scope'

	initialize: ->
		@dataService = @app_analysis_powercalc_allService

		@title = 'Power Calculator Module'
		@dataType = ''

		