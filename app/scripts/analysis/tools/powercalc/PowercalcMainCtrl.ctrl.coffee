'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcMainCtrl extends BaseCtrl
	@inject 'app_analysis_powercalc_cfap', '$timeout', 'scope'

	initialize: ->

		@cfap = @app_analysis_powercalc_cfap

		@title = 'Power Calculator Module'
		#algorithm type
		@is_cfap = off

		@$scope.$on 'powercalc:updateAlgorithm', (event, data)=>
			@is_cfap = data.cfap



	cfap_ckick: (obj) ->
  		cfap.clk(obj)

  	cfap_valiad: (id, data, event) ->
  		cfap.valiad(id, data, event)

  	cfap_submit: (id, key, value) ->
  		cfap.submit(id, key, value)

  	cfap_showDiv(sliderId, key) ->
  		cfap.showDiv(sliderId, key)





