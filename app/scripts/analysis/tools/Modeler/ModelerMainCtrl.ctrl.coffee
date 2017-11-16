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
    @loadData()


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
      modelData = @router.getChartData(@distribution, @params )
      modelData.stats = @params
      @$timeout => @modelData = modelData,
      5
      @syncData(@params)
      #@loadData()
      #@router.setParams(@distribution, @params)

      #@loadData()
      
      




  updateModelData: () ->
    console.log("Updating Model Data from Sliders")
    modelData = @router.getChartData(@distribution, @params )
    modelData.stats = @params
    @$timeout => @modelData = modelData,
    5


  syncData: (dataIn) ->
    @router.setParamsByName(@distribution, dataIn)
    @loadData()


  normalRetrieve: ()->
    @currParams = @router.getParamsByName(@distribution)
    @NormalStDev = @currParams.standardDev
    @NormalMean = @currParams.mean
    @NormalVariance =   @currParams.variance

    @NormalSliders()
    @updateModelData()



  loadData: () ->
    if (@distribution is "Normal")
      @normalRetrieve()
      return
    else if (@distribution is "Laplace")
      @laplaceRetrieve()
      return
    else
      return


  
  
  NormalSync: () ->
    @params.stats.mean = @NormalMean
    @params.stats.standardDev = @NormalStDev
    @params.stats.variance = @NormalVariance
    @syncData(@params)
    #@loadData()


  @NormalPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "Normal"
        @NormalSync()

  NormalSliders: () ->

    # select slider elements
    nMean = $("#NormalMean")
    nStDev = $("#NormalStDev")
    nVariance = $("#NormalVariance")
    # twoTestMean2UI = $("#twoTestMean2UI")
    # twoTestStDev1UI = $("#twoTestStDev1UI")
    # twoTestStDev2UI = $("#twoTestStDev2UI")
    # twoTestPowerUI = $("#twoTestPowerUI")
   
    nMean.slider(
      value: @NormalMean,
      min: 0,
      max: 30,
      range: "min",
      step: .5,
      slide: (event, ui) =>
        @NormalMean = ui.value
        @NormalSync()
    )

    nStDev.slider(
      value: @NormalStDev,
      min: 0,
      max: 10,
      range: "min",
      step: .2,
      slide: (event, ui) =>
        @NormalStDev = ui.value
        @NormalSync()
    )

    nVariance.slider(
      value: @NormalVariance,
      min: 0,
      max: 10,
      range: "min",
      step: 0.2,
      slide: (event, ui) =>
        @NormalVariance = ui.value
        @NormalSync()
    )

    

    # enable or disable sliders
    sliders = [
      nMean
      ]

    if @deployed is true
      for sl in sliders
        sl.slider("disable")
        sl.find('.ui-slider-handle').hide()
    else
      for sl in sliders
        sl.slider("enable")
        sl.find('.ui-slider-handle').show()
