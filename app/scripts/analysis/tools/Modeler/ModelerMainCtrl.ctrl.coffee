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
    @tempData = {}
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
      #console.log(data)
      #@stats = @getParams.getParams(data)
      @distribution = data.distribution.name
      console.log("distribution is : " + @distribution)
      #@chartData = data
      @tempData = data
      histData = data.dataPoints
      histData = histData.map (row) ->
            x: row[0]
            y: row[1]
            z: row[2]
            r: row[3]
      @stats  = @getParams.getParams(data)
      @params.stats = @stats
      @router.setParamsByName(@distribution, @params)
      
      
      @params.xMin = d3.min(histData, (d)->parseFloat d.x)
      @params.xMax = d3.max(histData, (d)->parseFloat d.x)


      #To be added for quantile
      console.log(@distribution)
      console.log(@params)
      @syncData(@params)
      #@loadData()
      #@router.setParams(@distribution, @params)

      #@loadData()






  updateModelData: () ->
    console.log("Updating Model Data from Sliders")
   
    #@modelData = @router.getChartData(@distribution, @params )
    #@modelData.stats = @params
    #modelData = @router.getChartData(@distribution, @params )
    #modelData.stats = @params
    
    xBounds = @getXbounds(@params, @distribution)
    @params.xMin = xBounds.xMin
    @params.xMax = xBounds.xMax
    modelData = @router.getChartData(@distribution, @params )
    modelData.stats = @params
    #tempData.bounds = xBounds
    @tempData.bounds =  @getYBounds(modelData)
    @chartData = @tempData
    console.log "updating chart data"
    #@$timeout => @chartData = @tempData,
    #5

    @$timeout => @modelData = modelData,
    5


  getXbounds: (@params, @distribution) ->
      dataSetxMin = @params.xMin
      dataSetxMax = @params.xMax
      
      modelDataFirstQuantile = @router.getQuantile(@distribution, @params, 0.01)
      modelDataNNQuantile = @router.getQuantile(@distribution, @params, 0.99)
      xMin = Math.min(modelDataFirstQuantile, dataSetxMin)
      xMax = Math.max(modelDataNNQuantile, dataSetxMax)
      #buggggggy value
      bounds =
        xMin: xMin
        xMax: xMax
        

  getYBounds: (modelData) ->
      modelDataYMax = d3.max(modelData, (d)->parseFloat d.y)
      bounds =
        yMax: modelDataYMax
  syncData: (dataIn) ->
    @router.setParamsByName(@distribution, dataIn)
    @loadData()





  resetGetParams: () ->
    @stats = @getParams.getParams(@chartData)
    @params.stats = @stats
    @syncData(@params)


  loadData: () ->
    if (@distribution is "Normal")
      @normalRetrieve()
      return
    else if (@distribution is "Laplace")
      @laplaceRetrieve()
      return
    else if (@distribution is "Cauchy")
      @CauchyRetrieve()
    else if (@distribution is "ChiSquared")
      @ChiSquaredRetrieve()
    else if (@distribution is "LogNormal")
      @LogNormalRetrieve()
    else if (@distribution is "Maxwell-Boltzman")
      @MaxBoltRetrieve()
    else if (@distribution is "Exponential")
      @ExponentialRetrieve()
    else
      return





  normalRetrieve: ()->
    @currParams = @router.getParamsByName(@distribution)
    @NormalStDev = @currParams.standardDev
    @NormalMean = @currParams.mean
    @NormalVariance =   @currParams.variance

    @NormalSliders()
    @updateModelData()


  NormalSync: () ->
    @params.stats.mean = @NormalMean
    @params.stats.standardDev = @NormalStDev
    @params.stats.variance = @NormalVariance
    @syncData(@params)
    #@loadData()



  NormalPress: (evt) ->
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
    nMean.slider(
      value: @NormalMean,
      min: 0.01,
      max: 30,
      range: "min",
      step: .5,
      slide: (event, ui) =>
        @NormalMean = ui.value
        @NormalSync()
    )

    nStDev.slider(
      value: @NormalStDev,
      min: 0.01,
      max: 10,
      range: "min",
      step: .2,
      slide: (event, ui) =>
        @NormalStDev = ui.value
        @NormalSync()
    )

    nVariance.slider(
      value: @NormalVariance,
      min: 0.01,
      max: 10,
      range: "min",
      step: 0.2,
      slide: (event, ui) =>
        @NormalVariance = ui.value
        @NormalSync()
    )
    # enable or disable sliders
    sliders = [
      nMean, nVariance, nStDev
      ]

    if @deployed is true
      for sl in sliders
        sl.slider("disable")
        sl.find('.ui-slider-handle').hide()
    else
      for sl in sliders
        sl.slider("enable")
        sl.find('.ui-slider-handle').show()



  laplaceRetrieve: () ->
    @currParams = @router.getParamsByName(@distribution)
    @LaplaceMean = @currParams.mean
    @LaplaceScale = @currParams.scale
    @LaplaceSliders()
    @updateModelData()



  LaplaceSync: () ->
    @params.stats.mean = @LaplaceMean
    @params.stats.scale = @LaplaceScale
    @syncData(@params)


  LaplacePress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "Laplace"
        @LaplaceSync()

  LaplaceSliders: () ->
    lMean = $("#LaplaceMean")
    lScale = $("#LaplaceScale")

    lMean.slider(
      value: @LaplaceMean,
      min: 0.01,
      max: 30,
      range: "min",
      step: .5,
      slide: (event, ui) =>
        @LaplaceMean = ui.value
        @LaplaceSync()
    )

    lScale.slider(
      value: @LaplaceScale,
      min: 0.01,
      max: 10,
      range: "min",
      step: .2,
      slide: (event, ui) =>
        @LaplaceScale = ui.value
        @LaplaceSync()
    )


  CauchyRetrieve: () ->
    @currParams = @router.getParamsByName(@distribution)
    @CauchyLocation = @currParams.location
    @CauchyGamma = @currParams.gamma
    @CauchySliders()
    @updateModelData()

  CauchySync: () ->
    @params.stats.location = @CauchyLocation
    @params.stats.gammma =  @CauchyGamma
    @syncData(@params)



  CauchyPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "Cauchy"
        @CauchySync()

  CauchySliders: () ->
    cLocation = $("#CLocation")
    cGamma = $("#CGamma")

    cLocation.slider(
      value: @CauchyLocation,
      min: 0.01,
      max: 10,
      range: "min",
      step: .2,
      slide: (event, ui) =>
        @CauchyLocation = ui.value
        @CauchySync()
    )



    cGamma.slider(
      value: @CauchyGamma,
      min: 0.01,
      max: 10,
      range: "min",
      step: .2,
      slide: (event, ui) =>
        @CauchyGamma = ui.value
        @CauchySync()
    )

  ChiSquaredRetrieve: () ->
    @currParams = @router.getParamsByName(@distribution)
    @k = @currParams.mean
    @ChiSquaredSliders()
    @updateModelData()



  ChiSquaredSync: () ->
    @params.stats.mean = @k

    @syncData(@params)


  ChiSquaredPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "ChiSquared"
        @ChiSquaredSync()

  ChiSquaredSliders: () ->
    kMean = $("#ChiSquared")

    kMean.slider(
      value: @k,
      min: 0.01,
      max: 10,
      range: "min",
      step: .5,
      slide: (event, ui) =>
        @k  = ui.value
        @ChiSquaredSync()
    )


  ExponentialRetrieve: () ->
    @currParams = @router.getParamsByName(@distribution)
    @gamma = @currParams.gamma
    @ExponentialSliders()
    @updateModelData()



  ExponentialSync: () ->
    @params.stats.gamma = @gamma

    @syncData(@params)


  ExponentialPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "Exponential"
        @ExponentialSync()

  ExponentialSliders: () ->
    ExpGam = $("#ExponentialGamma")

    ExpGam.slider(
      value: @gamma,
      min: 0.01,
      max: 10,
      range: "min",
      step: .5,
      slide: (event, ui) =>
        @gamma  = ui.value
        @ExponentialSync()
    )



  LogNormalRetrieve: ()->
    @currParams = @router.getParamsByName(@distribution)
    @LogNormalStDev = @currParams.standardDev
    @LogNormalMean = @currParams.mean
    console.log("in log normal retrieve!!!!!")
    @LogNormalSliders()
    @updateModelData()


  LogNormalSync: () ->
    @params.stats.mean = @LogNormalMean
    @params.stats.standardDev = @LogNormalStDev
    @syncData(@params)




  LogNormalPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "LogNormal"
        @LogNormalSync()

  LogNormalSliders: () ->
    logMean = $("#LogNormalMean")
    logStDev = $("#LogNormalStDev")
    logMean.slider(
      value: @LogNormalMean,
      min: 0.01,
      max: 10,
      range: "min",
      step: .1,
      slide: (event, ui) =>
        @LogNormalMean = ui.value
        @LogNormalSync()
    )

    logStDev.slider(
      value: @LogNormalStDev,
      min: 0.01,
      max: 10,
      range: "min",
      step: .2,
      slide: (event, ui) =>
        @LogNormalStDev = ui.value
        @LogNormalSync()
    )

    # enable or disable sliders
    sliders = [
      logMean, logStDev
    ]

    if @deployed is true
      for s3 in sliders
        s3.slider("disable")
        s3.find('.ui-slider-handle').hide()
    else
      for s3 in sliders
        s3.slider("enable")
        s3.find('.ui-slider-handle').show()




  MaxBoltRetrieve: () ->
      @currParams = @router.getParamsByName(@distribution)
      @MaxBoltA = @currParams.A
      @MaxBoltSliders()
      @updateModelData()



  MaxBoltSync: () ->
    @params.stats.A = @MaxBoltA
    @syncData(@params)


  MaxBoltPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "Maxwell-Boltzman"
        @MaxBoltSync()

  MaxBoltSliders: () ->
    a = $("#MaxBolt")
    a.slider(
      value: @MaxBoltA,
      min: 0.01,
      max: 30,
      range: "min",
      step: .2,
      slide: (event, ui) =>
        @MaxBoltA = ui.value
        @MaxBoltSync()
    )
