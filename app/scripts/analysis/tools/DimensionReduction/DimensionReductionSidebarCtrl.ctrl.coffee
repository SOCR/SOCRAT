'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class DimensionReductionSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_dimension_reduction_msgService',
    'app_analysis_dimension_reduction_dataService',
    '$scope',
    '$timeout'

  initialize: ->
    # initializing all modules
    @dataService = @app_analysis_dimension_reduction_dataService
    @msgService = @app_analysis_dimension_reduction_msgService

    # all dataSets
    @dataSets = ['CountryRanking',
    'UKBB']
    @selectedDataSet = @dataSets[0]
    @link = 'https://projector.tensorflow.org/?config=https://raw.githubusercontent.com/SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/SOCR_CountryRanking_projector_config.json'

    # Once the dataSet is updated, broadcast new link to mainArea
  updateDataSet: () ->
    #broadcast dataSet to main controller
    if (@selectedDataSet is 'CountryRanking')
      @link = 'https://projector.tensorflow.org/?config=https://raw.githubusercontent.com/SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/SOCR_CountryRanking_projector_config.json'
      @msgService.broadcast 'dimensionReduction:link',
        @link
      console.log(@link)

    if (@selectedDataSet is 'UKBB')
      @link = 'https://projector.tensorflow.org/?config=https://raw.githubusercontent.com/SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/SOCR_UKBB_projector_config.json'
      @msgService.broadcast 'dimensionReduction:link',
        @link
      console.log(@link)

