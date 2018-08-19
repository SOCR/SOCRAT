'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowerCalcMainCtrl extends BaseCtrl

  @inject 'app_analysis_powerCalc_msgService',
  'app_analysis_powerCalc_algorithms',
  '$timeout',
  '$scope'

  initialize: ->
    @powerAnalysis = require 'powercalc'
    @distribution = require 'distributome'
    @msgService = @app_analysis_powerCalc_msgService
    @algorithmService = @app_analysis_powerCalc_algorithms

    @title = 'Power Calculator Module'
    #algorithm type
    @selectedAlgorithm = "Test of One Proportion"
    @SIGNIFICANT = 5
    @dataType = ''
    @dataPoints = null
    @means = null
    @assignments = null
    @deployed = false
    @chosenCols = []
    @compAgents = []
    @agent = ""
    @params = {}
    @brokenCalc = false

    # initialize data for plotting
    @chartData = null
    @barChartData = null

    # show help
    @showHelp = false;
    @loadData()

    @$scope.$on 'powercalc:updateAlgorithm', (event, data)=>
      @selectedAlgorithm = data
      @showHelp = false
      console.log("algorithms updated:", @selectedAlgorithm)
      @loadData()
      MathJax.Hub.Queue(["Typeset",MathJax.Hub]);

    #receive data
    @$scope.$on 'powercalc:data', (event, data)=>
      @algorithmService.passDataByName(@selectedAlgorithm, data)
      @loadData()

    @$scope.$on 'powercalc:alpha', (event, data)=>
      @algorithmService.passAlphaByName(@selectedAlgorithm, data.alpha_in)
      @loadData()

    @$scope.$on 'powercalc:change_mode', (event, data)=>
      @deployed=data.deploy
      @loadData()

    @$scope.$on 'powercalc:updateDataPoints', (event, data) =>
      @data = data.dataPoints

  # retreive data parameters from algorithm services
  loadData: () ->
    if (@selectedAlgorithm is "Two-sample t test (general case)")
      @twoTestRetrieve()
      return
    else if (@selectedAlgorithm is "One-Sample (or Paired) t Test")
      @oneTestRetrieve()
      return
    else if (@selectedAlgorithm is "Test of One Proportion")
      @onePropRetrieve()
      return
    else if (@selectedAlgorithm is "Test of Two Proportions")
      @twoPropRetrieve()
      return
    else if (@selectedAlgorithm is "Generic chi-square test")
      @chi2Retrieve()
      return
    else if (@selectedAlgorithm is "Power of a Simple Poisson Test")
      @poissonRetrieve()
      return
    else if (@selectedAlgorithm is "R-square (multiple correlation)")
      @rSquareRetrieve()
      return
    else
      console.log("Unknown algorithms selected")
      return

  # send new data parameters to algorithm service (execpt power)
  syncData: (dataIn) ->
    @algorithmService.setParamsByName(@selectedAlgorithm, dataIn)
    @loadData()

  # send new power value to algorithm service
  syncPower: (dataIn) ->
    @algorithmService.setPowerByName(@selectedAlgorithm, dataIn)
    @loadData()

  showHelpToggle: () ->
    @showHelp = !@showHelp
    return




  #cfap function only
  cfap_clk: (evt) ->
    obj = evt.currentTarget
    #console.log(evt.currentTarget.value)
    if obj
      id=obj.id;
      ck=$(obj).prop("checked")
      if ck
        #console.log(evt.currentTarget.value)
        @cfap_submit("1",id,"1")
      else
        @cfap_submit("1",id,"")
    return

  cfap_valiad: (evt) ->
    id = evt.currentTarget.id
    data = evt.currentTarget.value
    e = event or window.event or arguments.callee.caller.arguments[0]
    r = /^\d+(\.\d+)?$/
    if r.test(data)
      @cfap_submit '1', id, data
    else
      return false
    return

  cfap_presubmit: (id, key, evt) ->
    @cfap_submit(id, key, evt.target.value)

  cfap_click: () ->
    $('#nui').slider(
      animate: 'slow'
      value: @cfap_n
      min: 0
      max: 400
      range: "min"
      step: 0.01
      slide: (event, ui) =>
        $('#n').val ui.value
        @cfap_submit '1', 'n', ui.value
        return
    )
    $('#n').val $('#nui').slider('value')
    $('#meui').slider(
      value: @cfap_me
      min: 0
      max: @cfap_maxme
      range: "min"
      step: 0.00001
      slide: (event, ui) =>
        $('#me').val ui.value
        @cfap_submit '1', 'ME', ui.value
        return
    )
    $('#me').val $('#meui').slider('value')
    $("#slider").slider(
      min: 0.80
      max: 0.99
      value: @cfap_conf_level
      orientation: "horizontal"
      range: "min"
      step: 0.01
      slide: (event, ui) =>
        @cfap_conf_level = ui.value
        $('#conf').val ui.value
        @cfap_submit '1', 'conf', ui.value
        return
    )
    return

  cfap_submit: (id, key, value) ->
    a = @powerAnalysis.cfap(id, key, value);
    if a.isFinite == 1
      $('#isFinite').prop 'checked', 'checked'
      $('#showN').show()
    else
      $('#isFinite').prop 'checked', ''
      $('#showN').hide()
    #N
    $('#N').val a.N
    #worstCase
    if a.worstCase == 1
      $('#worstCase').prop 'checked', 'checked'
    else
      $('#worstCase').prop 'checked', ''
    #pi
    $('#pi').val a.pi
    #Conf
    $('#conf').prop 'value', a.conf
    #ME
    $('#me').val a.ME
    #n
    $('#n').val a.n
    #check
    @cfap_me = a.ME
    if @cfap_me > @cfap_maxme
      @cfap_maxme = (@cfap_me / 0.02 + 1) * 0.02
    @cfap_n = a.n
    if @cfap_n > @cfap_maxn
      @cfap_maxn = (@cfap_n / 20 + 1) * 20
    @cfap_conf_level = a.conf
    @cfap_click()
    return
  cfap_changeSlider: (sliderId, evt) ->
    #console.log("changeSlider hit")
    key = evt.target.value
    console.log(key)
    @cfap_submit '1', sliderId, key
    return

  cfap_show_help: () ->
    # @render_mathjax()
    #console.log(@cfap_help)
    if (@cfap_help == true)
      $('#cfapH').val "Show Help"
    else
      $('#cfapH').val "Hide Help"
    @cfap_help = !@cfap_help;
    return


  #OneProp function only
  onePropRetrieve: () ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @onePropN = @params.n
    # console.log @params
    @onePropNMax = @params.nMax
    @onePropP = parseFloat(@params.p.toPrecision(4))
    @onePropP0 = parseFloat(@params.p0.toPrecision(4))
    @onePropPMax = parseFloat(@params.pMax.toPrecision(4))
    @onePropPower = parseFloat(@params.power.toPrecision(4))
    @onePropZ = parseFloat(@params.z.toPrecision(4))
    @onePropPvalue = parseFloat(@params.pvl.toPrecision(4))
    @onePropMode = @params.mode
    @onePropModes = ["Two Sided", "One Sided"]
    @onePropClick()
    @onePropGraph()
    if (@deployed)
      @compAgents = [@params.comp]
    else
      @compAgents = ["Sample"]
    return

  onePropSync: () ->
    @params.n = @onePropN
    @params.p = @onePropP
    @params.p0 = @onePropP0
    @params.mode = @onePropMode
    @syncData(@params)

  onePropCalcPower: () ->
    @params.power = @onePropPower
    @params.mode = @onePropMode
    @syncPower(@params)
    return

  onePropPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "onePropPower"
        @onePropCalcPower()
      else
        @onePropSync()
    return

  onePropClick: () ->
    #slider elements
    onePropPUI = $("#onePropPUI")
    onePropP0UI = $("#onePropP0UI")
    onePropNUI = $("#onePropNUI")
    onePropPowerUI = $("#onePropPowerUI")
    onePropSliders = [onePropPUI, onePropNUI, onePropPowerUI]

    onePropPUI.slider(
      value: @onePropP,
      min: 0,
      max: 1,
      range: "min",
      step: 0.001,
      slide: (event, ui) =>
        @onePropP = ui.value
        @onePropSync()
    )

    onePropP0UI.slider(
      value: @onePropP0,
      min: 0,
      max: 1,
      range: "min",
      step: 0.001,
      slide: (event, ui) =>
        @onePropP0 = ui.value
        @onePropSync()
    )

    onePropNUI.slider(
      value: @onePropN,
      min: 1,
      max: @onePropNMax,
      range: "min",
      step: 1,
      slide: (event, ui) =>
        @onePropN = ui.value
        @onePropSync()
    )

    onePropPowerUI.slider(
      value: @onePropPower,
      min: 0,
      max: 0.9999,
      range: "min",
      step: 0.001,
      slide: (event, ui) =>
        @onePropPower = ui.value
        @onePropCalcPower()
    )

    if @deployed is true
      for sl in onePropSliders
        sl.slider("disable")
        sl.find('.ui-slider-handle').hide()
    else
      for sl in onePropSliders
        sl.slider("enable")
        sl.find('.ui-slider-handle').show()

    onePropPowerUI.slider("disable")
    onePropPowerUI.find('.ui-slider-handle').hide()

    return

  onePropReset: () ->
    @reset()
    return

  onePropGraph: () ->
    @barChartData = null
    chartData = @algorithmService.getChartData @selectedAlgorithm
    @$timeout => @barChartData = chartData,
    5

  #twoProp
  twoPropRetrieve: () ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @twoPropP1 = parseFloat(@params.p1.toPrecision(4))
    @twoPropP2 = parseFloat(@params.p2.toPrecision(4))
    @twoPropN1 = @params.n1
    @twoPropN2 = @params.n2
    @twoPropNMax = @params.nMax
    @twoPropPower = parseFloat(@params.power.toPrecision(4))
    @twoPropMode = @params.mode
    if (@deployed)
      @compAgents = @params.comp
    else
      @compAgents = ["Sample1", "Sample2"]
    @twoPropModes = ["Two Sided", "One Sided"]
    @twoPropClick()
    @twoPropGraph()
    return

  twoPropSync: () ->
    @params.n1 = @twoPropN1
    @params.n2 = @twoPropN2
    @params.p1 = @twoPropP1
    @params.p2 = @twoPropP2
    @params.mode = @twoPropMode
    @syncData(@params)
    return

  twoPropCalcPower: () ->
    @params.power = @twoPropPower
    @params.mode = @twoPropMode
    @syncPower(@params)
    return

  twoPropPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "twoPropPower"
        @twoPropCalcPower()
      else
        @twoPropSync()
    return

  twoPropClick: () ->
    #slider elements
    twoPropP1UI = $("#twoPropP1UI")
    twoPropP2UI = $("#twoPropP2UI")
    twoPropN1UI = $("#twoPropN1UI")
    twoPropN2UI = $("#twoPropN2UI")
    twoPropPowerUI = $("#twoPropPowerUI")
    twoPropSlidersToDisable = [twoPropP1UI, twoPropP2UI, twoPropN1UI, twoPropN2UI]

    twoPropP1UI.slider(
      value: @twoPropP1,
      min: 0,
      max: 1,
      range: "min",
      step: 0.001,
      slide: (event, ui) =>
        @twoPropP1 = ui.value
        @twoPropSync()
    )

    twoPropP2UI.slider(
      value: @twoPropP2,
      min: 0,
      max: 1,
      range: "min",
      step: 0.001,
      slide: (event, ui) =>
        @twoPropP2 = ui.value
        @twoPropSync()
    )

    twoPropN1UI.slider(
      value: @twoPropN1,
      min: 0,
      max: @twoPropNMax,
      range: "min",
      step: 1,
      slide: (event, ui) =>
        @twoPropN1 = ui.value
        @twoPropSync()
    )

    twoPropN2UI.slider(
      value: @twoPropN2,
      min: 0,
      max: @twoPropNMax,
      range: "min",
      step: 1,
      slide: (event, ui) =>
        @twoPropN2 = ui.value
        @twoPropSync()
    )

    twoPropPowerUI.slider(
      value: @twoPropPower,
      min: 0,
      max: 1,
      range: "min",
      step: 0.001,
      slide: (event, ui) =>
        @twoPropPower = ui.value
        @twoPropCalcPower()
    )

    if @deployed is true
      for sl in twoPropSlidersToDisable
        sl.slider("disable")
        sl.find('.ui-slider-handle').hide()
    else
      for sl in twoPropSlidersToDisable
        sl.slider("enable")
        sl.find('.ui-slider-handle').show()

    twoPropPowerUI.slider("disable")
    twoPropPowerUI.find('.ui-slider-handle').hide()

    return

  twoPropReset: () ->
    @reset()
    return

  twoPropGraph: () ->
    @barChartData = null
    chartData = @algorithmService.getChartData @selectedAlgorithm
    @$timeout => @barChartData = chartData,
    5


  #functions for OneTGUI only
  oneTestRetrieve: () ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @oneTestN = @params.n
    @oneTestNMax = @params.nMax
    @oneTestMean = parseFloat(@params.mean.toPrecision(4))
    @oneTestMean0 = parseFloat(@params.mean0.toPrecision(4))
    @oneTestMeanMax = parseFloat(@params.meanMax.toPrecision(4))
    @oneTestMean0Max = parseFloat(@params.mean0Max.toPrecision(4))
    @oneTestStDev = parseFloat(@params.sigma.toPrecision(4))
    @oneTestSigmaMax = parseFloat(@params.sigmaMax.toPrecision(4))
    @oneTestPower = parseFloat(@params.power.toPrecision(4))
    @oneTestT = parseFloat(@params.t.toPrecision(4))
    @oneTestPvalue = parseFloat(@params.pvl.toPrecision(4))
    @oneTestMode = @params.mode
    @oneTestModes = ["Two Tailed", "One Tailed"]
    if @deployed is true then @compAgents = @params.comp
    else @compAgents = ["Sample", "Sample"]
    @oneTestClick()
    @oneTestGraph()
    return

  oneTestSync: () ->
    @params.n = @oneTestN
    @params.nMax = @oneTestNMax
    @params.mean = @oneTestMean
    @params.mean0 = @oneTestMean0
    @params.meanMax = @oneTestMeanMax
    @params.sigma = @oneTestStDev
    @params.sigmaMax = @oneTestSigmaMax
    @params.power = @oneTestPower
    @params.mode = @oneTestMode
    @syncData(@params)
    @loadData()
    return

  oneTestCalcPower: () ->
    @params.power = @oneTestPower
    @params.mode = @oneTestMode
    @syncPower(@params)
    return

  oneTestPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "oneTestPower" then @oneTestCalcPower()
      else @oneTestSync()
    return

  oneTestClick: () ->
    # slider elements
    oneTestNUI = $("#oneTestNUI")
    oneTestMean0UI = $("#oneTestMean0UI")
    oneTestMeanUI = $("#oneTestMeanUI")
    oneTestStDevUI= $("#oneTestStDevUI")
    oneTestPowerUI = $("#oneTestPowerUI")

    oneTestNUI.slider(
      value: @oneTestN,
      min: 2,
      max: @oneTestNMax,
      range: "min",
      step: 1,
      slide: (event, ui) =>
        @oneTestN = ui.value
        @oneTestSync()
    )

    oneTestMean0UI.slider(
      value: @oneTestMean0,
      min: 0,
      max: @oneTestMean0Max,
      range: "min",
      step: 0.001,
      slide: (event, ui) =>
        @oneTestMean0 = ui.value
        @oneTestSync()
    )

    oneTestMeanUI.slider(
      value: @oneTestMean,
      min: 0,
      max: @oneTestMeanMax,
      range: "min",
      step: 0.001,
      slide: (event, ui) =>
        @oneTestMean = ui.value
        @oneTestSync()
    )

    oneTestStDevUI.slider(
      value: @oneTestStDev,
      min: 0,
      max: @oneTestSigmaMax,
      range: 'min',
      step: 0.001,
      slide: (event, ui) =>
        @oneTestStDev = ui.value
        @oneTestSync()
    )

    oneTestPowerUI.slider(
      value: @oneTestPower,
      min: 0.0001,
      max: 0.9999,
      range: "min",
      step: 0.0001,
      slide:  (event, ui) =>
        @oneTestPower = ui.value
        @oneTestCalcPower()
    )

    # enable or disable slider
    sliders = [oneTestNUI, oneTestMeanUI, oneTestStDevUI, oneTestPowerUI]

    if @deployed is true
      for sl in sliders
        sl.slider("disable")
        sl.find('.ui-slider-handle').hide()
    else
      for sl in sliders
        sl.slider("enable")
        sl.find('.ui-slider-handle').show()

  oneTestGraph:() ->
    @chartData = null
    chartData = @algorithmService.getChartData @selectedAlgorithm
    @$timeout => @chartData = chartData,
    5


  #functions for RsquareGUI only
  RsquareGUI_click: () ->
    $( "#rho2uif" ).slider(
      value:@RsquareGUI_rho2,
      min: 0,
      max: @RsquareGUI_maxrho2,
      range: "min",
      step: 0.00001,
      slide: ( event, ui ) =>
        $( "#rho2" ).val( ui.value );
        @RsquareGUI_submit('1','rho2',ui.value);
        return
    )

    $( "#nuif" ).slider(
      value:@RsquareGUI_n,
      min: 0,
      max: @RsquareGUI_maxn,
      range: "min",
      step: 0.005,
      slide: ( event, ui ) =>
        $( "#nf" ).val( ui.value );
        @RsquareGUI_submit('1','n',ui.value);
        return
    )

    $( "#predsuif" ).slider(
      value:@RsquareGUI_preds,
      min: 0,
      max: @RsquareGUI_maxpreds,
      range: "min",
      step: 0.0001,
      slide: ( event, ui ) =>
        $( "#predsf" ).val( ui.value );
        @RsquareGUI_submit('1','preds',ui.value);
        return
    )

    $( "#poweruif" ).slider(
      value:@RsquareGUI_power,
      min: 0,
      max: @RsquareGUI_maxpower,
      range: "min",
      step: 0.0001,
      disabled:true
    )

    $( "#rho2f" ).val( $( "#rho2uif" ).slider( "value" ) );
    $( "#nf" ).val( $( "#nuif" ).slider( "value" ) );
    $( "#predsf" ).val( $( "#predsuif" ).slider( "value" ) );
    $( "#powerf" ).val( $( "#poweruif" ).slider( "value" ) );
  RsquareGUI_clk: (evt) ->
    obj=evt.currentTarget
    if obj
      id=obj.id;
      ck=$(obj).prop("checked");
      if ck
        @RsquareGUI_submit("1",id,"1");
      else
        @RsquareGUI_submit("1",id,"");
  RsquareGUI_submit: (id, key, value) ->
    d = @powerAnalysis.RsquareGUI_handle(id, key, value);
    $("#alphaf").val(d.alpha);
    $("#rho2f").val(d.rho2);
    @RsquareGUI_rho2 = d.rho2;
    $("#nf").val(d.n);
    $("#predsf").val(d.preds);
    @RsquareGUI_n = d.n;
    @RsquareGUI_preds = d.preds;
    $("#powerf").val(d.power);
    @RsquareGUI_power = d.power;
    @RsquareGUI_click();
  RsquareGUI_valiad: (evt) ->
    id = evt.currentTarget.name
    data = evt.currentTarget.value
    e = event || window.event || arguments.callee.caller.arguments[0];
    r=/^\d+(\.\d+)?$/;
    if r.test(data)
      @RsquareGUI_submit('1','alpha',data);
      return true;
    else
      return true;
  RsquareGUI_changeSlider: (sliderId, evt) ->
    #console.log("changeSlider hit")
    key = evt.target.value
    @RsquareGUI_submit '1', sliderId, key
    return
  RsquareGUI_show_help: () ->
    #console.log(@cfap_help)
    if (@RsquareGUI_help == true)
      $('#RsquareGUI_H').val "Show Help"
    else
      $('#RsquareGUI_H').val "Hide Help"
    @RsquareGUI_help = !@RsquareGUI_help
    return

  rSquareRetrieve: () ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @rSquareRHO2 = @params.rho2
    @rSquaren = @params.n
    @rSquarenMax = @params.nMax
    @rSquarePreds = @params.preds
    @rSquarePredsMax = @params.predsMax
    @rSquarePower = parseFloat(@params.power.toPrecision(2))
    @rSquareClick()

  rSquareClick: () ->
      rSquareRHO2UI = $("#rSquareRHO2UI")
      rSquarenUI = $("#rSquarenUI")
      rSquarePredsUI = $("#rSquarePredsUI")
      rSquarePowerUI = $("#rSquarePowerUI")

      rSquareRHO2UI.slider(
        value: @rSquareRHO2,
        min: 0,
        max: 0.99,
        range: 'min',
        step: 0.01,
        slide: (event, ui) =>
          @rSquareRHO2 = ui.value
          @rSquareSync("rho2")
          @$scope.$apply()
      )

      rSquarenUI.slider(
        value: @rSquaren,
        min: @rSquarePreds+1,
        max: @rSquarenMax,
        range: 'min',
        step: 1,
        slide: (event, ui) =>
          @rSquaren = ui.value
          @rSquareSync("n")
          @$scope.$apply()
      )

      rSquarePredsUI.slider(
        value: @rSquarePreds,
        min: 1,
        max: @rSquarePredsMax,
        range: 'min',
        step: 1,
        slide: (event, ui) =>
          @rSquarePreds = ui.value
          @rSquareSync("preds")
          @$scope.$apply()
      )

      rSquarePowerUI.slider(
        value: @rSquarePower,
        min: 0,
        max: 1,
        range: 'min',
        step: 0.01
      )

      rSquarePowerUI.slider("disable")
      rSquarePowerUI.find('.ui-slider-handle').hide()

  rSquareSync: (tar) ->
    @params.tar = tar
    @params.rho2 = @rSquareRHO2
    @params.n = @rSquaren
    @params.preds = @rSquarePreds
    @syncData(@params)
    return

  chi2Retrieve: () ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @chi2Power = parseFloat(@params.power.toPrecision(4))
    @chi2chi2 = @params.chi2
    @chi2chi2Max = @params.chi2Max
    @chi2EffSize = @params.effSize
    @chi2N = @params.n
    @chi2NMax = @params.nMax
    @chi2Df = @params.df
    @chi2DfMax = @params.dfMax
    @chi2Click()

  chi2Click:() ->
    chi2chi2UI = $("#chi2chi2UI")
    chi2EffSizeUI = $("#chi2EffSizeUI")
    chi2NUI = $("#chi2NUI")
    chi2DfUI = $("#chi2DfUI")
    chi2PowerUI = $("#chi2PowerUI")
    sliders = [chi2chi2UI, chi2EffSizeUI, chi2NUI, chi2DfUI, chi2PowerUI];

    chi2chi2UI.slider(
      value: @chi2chi2,
      min: 0,
      max: @chi2chi2Max,
      range: "min",
      step: 0.01,
      slide: (event, ui) =>
        @chi2chi2 = ui.value
        @chi2Sync("chi2")
        @$scope.$apply()
    )

    chi2EffSizeUI.slider(
      value: @chi2EffSize,
      min: 0,
      max: 1,
      range: "min",
      step: 0.01,
      slide: (event, ui) =>
        @chi2EffSize = ui.value
        @chi2Sync("effSize")
        @$scope.$apply()
    )

    chi2NUI.slider(
      value: @chi2N,
      min: 1,
      max: @chi2NMax,
      range: "min",
      step: 1,
      slide: (event, ui) =>
        @chi2N = ui.value
        @chi2Sync("n")
        @$scope.$apply()
    )

    chi2DfUI.slider(
      value: @chi2Df,
      min: 1,
      max: @chi2DfMax,
      range: "min",
      step: 1,
      slide: (event, ui) =>
        @chi2Df = ui.value
        @chi2Sync("df")
        @$scope.$apply()
    )

    chi2PowerUI.slider(
      value: @chi2Power,
      min: 0,
      max: 0.99,
      range: "min",
      step: 0.01,
      slide: (event, ui) =>
        @chi2Power = ui.value
        @$scope.$apply()
    )

    return

  chi2Sync: (tar) ->
    @params.target = tar
    @params.chi2 = @chi2chi2
    @params.effSize = @chi2EffSize
    @params.n = @chi2N
    @params.df = @chi2Df
    @params.power = @chi2Power
    @syncData(@params)
    return

  poissonRetrieve: () ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @poissonUpperBound = @params.upper
    @poissonLowerBound = @params.lower
    @poissonLambda0 = @params.lambda0
    @poissonLambda1 = @params.lambda1
    @poissonLambdaMax = @params.lambdaMax
    @poissonSize = @params.n
    @poissonSizeMax = @params.nMax
    @poissonPower = @params.power
    @poissonMode = @params.alt
    @poissonModes = ["lambda < lambda0", "lambda != lambda0", "lambda > lambda0"]
    @poissonClick()
    return

  poissonSync: (tar) ->
    @params.lambda0 = @poissonLambda0
    @params.lambda1 = @poissonLambda1
    @params.n = @poissonSize
    @params.alt = @poissonMode
    @params.target = tar
    @syncData(@params)
    return

  poissonClick: () ->
    poissonLambda0UI = $("#poissonLambda0UI")
    poissonLambda1UI = $("#poissonLambda1UI")
    poissonSizeUI = $("#poissonSizeUI")
    poissonPowerUI = $("#poissonPowerUI")
    sliders = [
      poissonLambda0UI,
      poissonLambda1UI,
      poissonSizeUI,
      poissonPowerUI,
    ]

    poissonLambda0UI.slider(
      value: @poissonLambda0,
      min: 0,
      max: @poissonLambdaMax,
      range: "min",
      step: 0.01,
      slide: (event, ui) =>
        @poissonLambda0 = ui.value
        @poissonSync("lambda0")
        @$scope.$apply()
    )

    poissonLambda1UI.slider(
      value: @poissonLambda1,
      min: 0,
      max: @poissonLambdaMax,
      range: "min",
      step: 0.01,
      slide: (event, ui) =>
        @poissonLambda1 = ui.value
        @poissonSync("lambda1")
        @$scope.$apply()
    )

    poissonSizeUI.slider(
      value: @poissonSize,
      min: 0,
      max: @poissonSizeMax,
      range: "min",
      step: 1,
      slide: (event, ui) =>
        @poissonSize = ui.value
        @poissonSync("n")
        @$scope.$apply()
    )

    poissonPowerUI.slider(
      value: @poissonPower,
      min: 0,
      max: 1,
      range: "min",
      step: 0.01,
      slide: (event, ui) =>
        @poissonPower = ui.value
        @poissonSync("power")
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





  twoTestRetrieve: () ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @twoTestN1 = @params.n1
    @twoTestN2 = @params.n2
    @twoTestMaxN = @params.nMax
    @twoTestMean1 = parseFloat(@params.mean1.toPrecision(4))
    @twoTestMean2 = parseFloat(@params.mean2.toPrecision(4))
    @twoTestMeanMax = parseFloat(@params.meanMax.toPrecision(4))
    @twoTestStDev1 = parseFloat(@params.sigma1.toPrecision(4))
    @twoTestStDev2 = parseFloat(@params.sigma2.toPrecision(4))
    @twoTestStDevMax = parseFloat(@params.sigmaMax.toPrecision(4))
    @twoTestPower = parseFloat(@params.power.toPrecision(4))
    @twoTestT = parseFloat(@params.t.toPrecision(4))
    @twoTestPvalue = parseFloat(@params.pvl.toPrecision(4))
    @twoTestMode = @params.mode
    if @deployed is true then @compAgents = ["S1:"+@params.comp[0], "S2:"+@params.comp[1]]
    else @compAgents = ["Sample1", "Sample2"]
    @twoTestModes = ["Two Tailed", "One Tailed"]
    @twoTestClick()
    if (@twoTestN2 is Infinity) or (@twoTestN1 is Infinity)
      @brokenCalc = true
      return
    @twoTestGraph()
    return

  twoTestSync: () ->
    @params.n1 = @twoTestN1
    @params.n2 = @twoTestN2
    @params.nMax = @twoTestMaxN
    @params.mean1 = @twoTestMean1
    @params.mean2 = @twoTestMean2
    @params.meanMax = @twoTestMeanMax
    @params.sigma1 = @twoTestStDev1
    @params.sigma2 = @twoTestStDev2
    @params.sigmaMax = @twoTestStDevMax
    @params.power = @twoTestPower
    @params.mode = @twoTestMode
    @syncData(@params)
    return

  twoTestCalcPower: () ->
    @params.power = @twoTestPower
    @params.mode = @twoTestMode
    @syncPower(@params)
    return

  twoTestPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "twoTestPower"
        @twoTestCalcPower()
      else
        @twoTestSync()
    return

  twoTestClick: () ->

    # select slider elements
    twoTestN1UI = $("#twoTestN1UI")
    twoTestN2UI = $("#twoTestN2UI")
    twoTestMean1UI = $("#twoTestMean1UI")
    twoTestMean2UI = $("#twoTestMean2UI")
    twoTestStDev1UI = $("#twoTestStDev1UI")
    twoTestStDev2UI = $("#twoTestStDev2UI")
    twoTestPowerUI = $("#twoTestPowerUI")

    twoTestN1UI.slider(
      value: @twoTestN1,
      min: 2,
      max: @twoTestMaxN,
      range: "min",
      step: 1,
      slide: (event, ui) =>
        @twoTestN1 = ui.value
        @twoTestSync()
    )

    twoTestN2UI.slider(
      value: @twoTestN2,
      min: 2,
      max: @twoTestMaxN,
      range: "min",
      step: 1,
      slide: (event, ui) =>
        @twoTestN2 = ui.value
        @twoTestSync()
    )

    twoTestMean1UI.slider(
      value: @twoTestMean1,
      min: 0,
      max: @twoTestMeanMax,
      range: "min",
      step: 0.01,
      slide: (event, ui) =>
        @twoTestMean1 = ui.value
        @twoTestSync()
    )

    twoTestMean2UI.slider(
      value: @twoTestMean2,
      min: 0,
      max: @twoTestMeanMax,
      range: "min",
      step: 0.01,
      slide: (event, ui) =>
        @twoTestMean2 = ui.value
        @twoTestSync()
    )

    twoTestStDev1UI.slider(
      value: @twoTestStDev1,
      min: 0,
      max: @twoTestMeanMax,
      range: "min",
      step: 0.01,
      slide: (event, ui) =>
        @twoTestStDev1 = ui.value
        @twoTestSync()
    )

    twoTestStDev2UI.slider(
      value: @twoTestStDev2,
      min: 0,
      max: @twoTestMeanMax,
      range: "min",
      step: 0.01,
      slide: (event, ui) =>
        @twoTestStDev2 = ui.value
        @twoTestSync()
    )

    twoTestPowerUI.slider(
      value: @twoTestPower,
      min: 0.0001,
      max: 0.9999,
      range: "min",
      step: 0.0001,
      slide: (event, ui) =>
        @twoTestPower = ui.value
        @twoTestCalcPower()
    )

    # enable or disable sliders
    sliders = [
      twoTestN1UI,
      twoTestN2UI,
      twoTestMean1UI,
      twoTestMean2UI,
      twoTestStDev1UI,
      twoTestStDev2UI,
      twoTestPowerUI
      ]

    if @deployed is true
      for sl in sliders
        sl.slider("disable")
        sl.find('.ui-slider-handle').hide()
    else
      for sl in sliders
        sl.slider("enable")
        sl.find('.ui-slider-handle').show()



  twoTestReset: () ->
    @reset()

  twoTestGraph:() ->
    @chartData = null
    chartData = @algorithmService.getChartData @selectedAlgorithm
    @$timeout => @chartData = chartData,
    5
