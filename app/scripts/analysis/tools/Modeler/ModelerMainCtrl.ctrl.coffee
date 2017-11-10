'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ModelerMainCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService',
    'socrat_analysis_modeler_getParams',
    'socrat_analysis_modeler_router'
    '$timeout',
    '$scope'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @DATA_TYPES = @dataService.getDataTypes()
    @router = @socrat_analysis_modeler_router
    @title = 'Modeling Module'
    @dataType = ''
    @dataPoints = null
    @assignments = null
    @distribution = 'Normal'
    @stats = null
    @modelData = {}
    @params = {}
    @getParams = @socrat_analysis_modeler_getParams
    #@gMean = 0
    #@gVariance =0
    #@gstandardDev = null



    @$scope.$on 'modeler:updateDataPoints', (event, data) =>
      #@showresults = off if @showresults is on
      # safe enforce $scope.$digest to activate directive watchers
      @$timeout => @updateChartData(data)

    @$scope.$on 'modeler:updateDataType', (event, dataType) =>
      console.log("broadcast occurered, updating datatTYPE")
      @dataType = dataType



  updateChartData: (data) ->
    if data.dataPoints?
      console.log("updatating chartData")
      console.log(data)
      #@stats = @getParams.getParams(data)
      @distribution = data.distribution.name
      console.log("distribution is : " + @distribution)
      @chartData = data
      histData = data.dataPoints
      histData = histData.map (row) ->
            x: row[0]
            y: row[1]
            z: row[2]
            r: row[3]
      @stats  = @getParams.getParams(data)
      @params.stats = @stats
      @params.xMin = d3.min(histData, (d)->parseFloat d.x)
      @params.xMax = d3.max(histData, (d)->parseFloat d.x)
      @modelData = @router.getChartData(@distribution, @params )
      console.log(@distribution)
      console.log(@params)
      @modelData.stats = @params





  updateModelData: () ->
    console.log("Updating Model Data from Sliders")

    #@params.stats.mean = parseFloat(@gMean.toPrecision(4))
    #@params.stats.standardDev = parseFloat(@gstandardDev.toPrecision(4))
    #@params.stats.variance = parseFloat(@gVariance.toPrecision(4))


    @modelData = @router.getChartData(@distribution, @params )
    @modelData.stats = @params
