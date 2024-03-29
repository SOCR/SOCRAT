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

    @datasetsName = @dataSet.getNames()


  avalDatasetControl: ->
    if document.getElementById("aval-dataset").style.display == "none" ||
       document.getElementById("aval-dataset").style.display == ""
        document.getElementById("aval-dataset").setAttribute("style", "display: block")
        document.getElementById("menu-up").setAttribute("style", "display: inline-block")
        document.getElementById("menu-down").setAttribute("style", "display: none")
    else
        document.getElementById("aval-dataset").setAttribute("style", "display: none")
        document.getElementById("menu-up").setAttribute("style", "display: none")
        document.getElementById("menu-down").setAttribute("style", "display: inline-block")

  # Once the dataSet is updated, broadcast new link to mainArea
  # updateDataSet: () ->
  #   #broadcast dataSet to main controller
  #   @link = @dataSet.getUrlByName(@selectedDataSet)
  #   @msgService.broadcast 'dimensionReduction:link',
  #     @link
