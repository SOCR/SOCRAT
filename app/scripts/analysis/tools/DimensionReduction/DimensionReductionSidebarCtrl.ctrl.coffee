'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class DimensionReductionSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_dimension_reduction_dataSetConfig',
          'app_analysis_dimension_reduction_msgService',
          'app_analysis_dimension_reduction_dataService',
          '$scope',
          '$timeout'

  initialize: ->
    # initializing all modules
    @dataService = @app_analysis_dimension_reduction_dataService
    @msgService = @app_analysis_dimension_reduction_msgService
    @dataSet = @app_analysis_dimension_reduction_dataSetConfig

    # TODO: find a way to bypass same origin, and get the json names from github
    # $.ajax 'https://github.com/SOCR/HTML5_WebSite/tree/master/HTML5/SOCR_TensorBoard_UKBB/data/', {}, (response) -> 
    #   console.log(response)
      
    # url = 'https://github.com/SOCR/HTML5_WebSite/tree/master/HTML5/SOCR_TensorBoard_UKBB/data/'

    # $.ajax(
    #   type: 'GET'
    #   url: url
    #   ).done (o) ->
    #   console.log(o)
    #   return

    @datasetsName = @dataSet.getNames()

    # @selectedDataSet = names[0]

  # Once the dataSet is updated, broadcast new link to mainArea
  # updateDataSet: () ->
  #   #broadcast dataSet to main controller
  #   @link = @dataSet.getUrlByName(@selectedDataSet)
  #   @msgService.broadcast 'dimensionReduction:link',
  #     @link
