'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class StatsMainCtrl extends BaseCtrl
  @inject 'app_analysis_stats_msgService',
  'app_analysis_stats_algorithms',
  '$timeout',
  '$scope'

  initialize: ->

    # required basic modules
    @d3 = require 'd3'
    @ve = require 'vega-embed'
    @vt = require 'vega-tooltip/build/vega-tooltip.js'
    @distribution = require 'distributome'
    @msgService = @app_analysis_stats_msgService
    @algorithmService = @app_analysis_stats_algorithms
    @title = "Stats Analysis Module"
    @showHelp = false

    @selectedAlgorithm = "CI for One Mean"

    @loadData()


    @$scope.$on 'stats:alpha', (event, data)=>
      @algorithmService.passAlphaByName(@selectedAlgorithm, data)
      @loadData()

    # receive updated algorithm from sidebar area
    @$scope.$on 'stats:updateAlgorithm', (event, data)=>
      @selectedAlgorithm = data
      console.log("algorithms updated:", @selectedAlgorithm)
      @loadData()
      MathJax.Hub.Queue(["Typeset",MathJax.Hub]);

    # receive data
    @$scope.$on 'stats:Data', (event, data)=>
      @algorithmService.passDataByName(@selectedAlgorithm, data)
      @loadData()


  # load data to a specified calculator
  loadData: () ->
    if (@selectedAlgorithm is "CI for One Mean") then @CIOMRetrieve()
    else if (@selectedAlgorithm is "CI for One Proportion") then @CIOPRetrieve()
    else if (@selectedAlgorithm is "Pilot Study") then @PilotStudyRetrieve()
    else return

  # outdated
  update_algo: (evt) ->
    console.log(@selectedAlgorithm)
    @selectedAlgorithm = evt.currentTarget.value
    @msgService.broadcast 'powercalc:updateAlgorithm_back',
      @selectedAlgorithm

  # call to update data parameters of specified calculator
  syncData: (dataIn) ->
    @algorithmService.setParamsByName(@selectedAlgorithm, dataIn)
    @loadData()

  showHelpToggle: () ->
    @showHelp = !@showHelp
    return


  # functions for CIOM only
  # retrieve data parameters from specified calculators
  CIOMRetrieve: () ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @CIOMN = @params.n
    @CIOMNMax = @params.nMax
    @CIOMMean = @params.mu
    @CIOMMeanMax = @params.meanMax
    @CIOMStDev = @params.sigma
    @CIOMSigmaMax = @params.sigmaMax
    @CIOMTScore = @params.t
    @CIOMLowerBound = @params.lowBound
    @CIOMUpperBound = @params.upBound
    @CIOMMode = @params.mode
    @CIOMModes = ["Two Tailed", "One Tailed"]
    @CIOMClick()
    @CIOMDraw()
    return


  CIOMDraw: () ->

    confidenceInterval = [{"lowerBound":@CIOMLowerBound}, {"mean":@CIOMMean}, {"upperBound":@CIOMUpperBound}]
    title = "LowerBound: ".concat (@CIOMLowerBound).toString()
    title = title.concat " Mean: "
    title = title.concat (@CIOMMean).toString()
    title = title.concat " UpperBound: "
    title = title.concat (@CIOMUpperBound).toString()

    vlSpec =
      {
        "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
        "width": 550,
        "height": 200,
        "data": {"values": confidenceInterval},
        "layer": [{
          "mark": {"type": "point", "filled": true},
          "encoding": {
            "x": {
              "field": "mean", "type": "quantitative",
              "axis": {"title": title}
            },
            "color": {"value": "black"},
          }
        },
        {
          "mark": "rule",
          "encoding": {
            "x": {
              "aggregate": "ci0", "field": "lowerBound", "type": "quantitative"
            },
            "x2": {
              "aggregate": "ci1", "field": "upperBound", "type": "quantitative"
            }
          }
        }]
      }
    opt = {mode: "vega-lite", "actions": {export: true, source: false, editor: true}}
    @ve('#visCIOM', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )

  # call syncData
  CIOMSync: () ->
    @params.n = @CIOMN
    @params.mu = @CIOMMean
    @params.sigma = @CIOMStDev
    @params.mode = @CIOMMode
    @syncData(@params)
    return

  # if user press enter, then sync data parameters
  # otherwise, do nothing
  CIOMPress: (evt) ->
    key = evt.which or evt.keyCode
    if key is 13
      @CIOMSync()
    return

  # update all sliders
  # and check deployment of data mode
  CIOMClick: () ->
    # slider elements
    CIOMNUI = $("#CIOMNUI")
    CIOMMeanUI = $("#CIOMMeanUI")
    CIOMStDevUI= $("#CIOMStDevUI")

    CIOMNUI.slider(
      value: @CIOMN,
      min: 2,
      max: @CIOMNMax,
      range: "min",
      step: 1,
      slide: (event, ui) =>
        @CIOMN = ui.value
        @CIOMSync()
        @$scope.$apply()
    )

    CIOMMeanUI.slider(
      value: @CIOMMean,
      min: 0,
      max: @CIOMMeanMax,
      range: "min",
      step: 0.001,
      slide: (event, ui) =>
        @CIOMMean = ui.value
        @CIOMSync()
        @$scope.$apply()
    )

    CIOMStDevUI.slider(
      value: @CIOMStDev,
      min: 0,
      max: @CIOMSigmaMax,
      range: "min",
      step: 0.001,
      slide: (event, ui) =>
        @CIOMStDev = ui.value
        @CIOMSync()
        @$scope.$apply()
    )


    # enable or disable slider
    CIOMSliders = [CIOMNUI, CIOMMeanUI, CIOMStDevUI]
    if @deployed is true
      for sl in CIOMSliders
        sl.slider("disable")
        sl.find('.ui-slider-handle').hide()
    else
      for sl in CIOMSliders
        sl.slider("enable")
        sl.find('.ui-slider-handle').show()

    return

  # functions for CIOP only
  CIOPRetrieve:() ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @CIOPP = @params.p #central point
    @CIOPN = @params.n #sample size
    @CIOPT = @params.t #t-score
    @CIOPTMax = @params.tMax
    @zscore = @params.z
    @upbound = @params.u #from confinterval
    @lowbound = @params.l
    @confinterval = @params.ci
    @ciAlpha = @params.a #significance level
    @standarddev = @params.sd
    @cilevel = 1.0 - @ciAlpha #confidence level
    @CIOPChart()#show chart
    @CIOPClick()

  CIOPSync: () ->
    @params.p = @CIOPP
    @params.n = @CIOPN
    @params.t = @CIOPT
    @syncData(@params)

  CIOPPress: (evt) ->
    key = evt.which or evt.keyCode
    if key is 13
      @CIOMSync()
    return

  CIOPClick: () ->
    #slider elements
    CIOPNUI = $("#CIOPNUI")
    CIOPTUI = $("#CIOPTUI")
    sliders = [CIOPNUI, CIOPTUI]

    CIOPNUI.slider(
      value: @CIOPN,
      min: 0,
      max: @CIOPTMax,
      range: 'min',
      step: 1,
      slide: (event, ui) =>
        @CIOPN = ui.value
        @CIOPSync()
        @$scope.$apply()
    )

    CIOPTUI.slider(
      value: @CIOPT,
      min: 0,
      max: @CIOPTMax,
      range: 'min',
      step: 1,
      slide: (event, ui) =>
        @CIOPT = ui.value
        @CIOPSync()
        @$scope.$apply()
    )

    if @deployed is true
      for sl in sliders
        sl.slider("disable")
        sl.find('.ui-slider-handle').hide()
    else
      for sl in sliders
        sl.slider("enable")
        sl.find('.ui-slider-handle').show()
    return

  #Chart Visualization
  CIOPChart:() ->
    @ve = require 'vega-embed'
    nums = [{"lower" : @lowbound}, {"upper" : @upbound}, {"center" : @CIOPP}]
    title = "LowerBound: ".concat (@lowbound.toFixed(3)).toString()
    title = title.concat " Center: "
    title = title.concat (@CIOPP.toFixed(3)).toString()
    title = title.concat " UpperBound: "
    title = title.concat (@upbound.toFixed(3)).toString()
    vlSpec = {
      "width": 550,
      "height": 200,
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "data": {"values": nums},
      "layer": [{
        "mark": {"type": "point", "filled": true},
        "encoding": {
          "x": {
            "aggregate": "mean", "field": "center", "type": "quantitative",
            "scale": {"zero": false},
            "axis": {"title": "Interval"}
          }
          "color": {"value": "black"}
        }
      }, {
        "mark": "rule",
        "encoding": {
          "x": {
            "aggregate": "ci0", "field": "lower", "type": "quantitative",
            "scale": {"zero": false},
          },
          "x2": {
            "aggregate": "ci1", "field": "upper", "type": "quantitative"
          }
        }
      }]
    }
    opt = "actions": {export: true, source: false, editor: false}
    #Embed the visualization in the container with id `vis`
    @ve '#visCIOP', vlSpec, opt, (error, result) ->

  #example update function in chi squared service update
  PilotStudyRetrieve:() ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @PILOTP = @params.p #Percent Under
    @PILOTR = parseFloat(@params.r.toPrecision(3)) #Risk Exceeded
    @PILOTD = @params.d #Degrees of Freedom
    @prMax = @params.rMax
    @pdfMax = @params.dfMax
    @ppMax = @params.pMax

    @PilotClick()
    return

  PilotClick: () ->
    #slider elements

    PILOTPUI = $("#PILOTPUI")
    PILOTRUI = $("#PILOTRUI")
    PILOTDUI = $("#PILOTDUI")
    sliders = [PILOTPUI, PILOTDUI, PILOTDUI]


    PILOTPUI.slider(
      value: @PILOTP,
      min: 0,
      max: @ppMax,
      range: 'min',
      step: 1,
      slide: (event, ui) =>
        @PILOTP = ui.value
        @PilotSync("pctUnder")
        @$scope.$apply()
    )

    PILOTRUI.slider(
      value: @PILOTR,
      min: 0,
      max: @prMax,
      range: 'min',
      step: 0.01,
      slide: (event, ui) =>
        @PILOTR = ui.value
        @PilotSync("risk")
        @$scope.$apply()
    )

    PILOTDUI.slider(
      value: @PILOTD,
      min: 0,
      max: @pdfMax,
      range: 'min',
      step: 1,
      slide: (event, ui) =>
        @PILOTD = ui.value
        @PilotSync("df")
        @$scope.$apply()
    )
    PILOTRUI.slider("disable")
    PILOTRUI.find('.ui-slider-handle').hide()

    #enable or disable slider?
    if @deployed is true
      for sl in sliders
        sl.slider("disable")
        sl.find('.ui-slider-handle').hide()
    else
      for sl in sliders
        sl.slider("enable")
        sl.find('.ui-slider-handle').show()
    return

  PilotPress: (evt) ->
    key = evt.which or evt.keyCode
    if key is 13
      @PilotSync("pctUnder")
    return

  PilotSync: (tar) ->
    @params.p = @PILOTP
    @params.r = @PILOTR
    @params.d = @PILOTD
    @params.tar = tar
    @syncData(@params)
    return
