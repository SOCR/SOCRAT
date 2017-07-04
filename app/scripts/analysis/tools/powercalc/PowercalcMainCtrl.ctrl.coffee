'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcMainCtrl extends BaseCtrl
  @inject 'app_analysis_powercalc_msgService',
  'app_analysis_powercalc_algorithms',
  'app_analysis_powercalc_oneTest',
  '$timeout',
  '$scope'

  initialize: ->
    console.log("mainArea initialized")

    @powerAnalysis = require 'powercalc'
    @distribution = require 'distributome'
    @msgService = @app_analysis_powercalc_msgService
    @algorithmService = @app_analysis_powercalc_algorithms

    @title = 'Power Calculator Module'
    #algorithm type
    @selectedAlgorithm = "Two-sample t test (general case)"
    @SIGNIFICANT = 5
    @data = []
    @dataType = ''
    @dataPoints = null
    @means = null
    @assignments = null
    @populations = {}
    @deployed = false
    @chosenCols = []
    @comp_agents = []
    @agent = ""
    @params = {}
    @brokenCalc = false

    # initialize data for plotting
    @chartData = null

    #variables needed for cfap only
    @cfap_nn = 1
    @cfap_me=0.09297
    @cfap_n=101
    @cfap_maxn=120
    @cfap_maxme=0.12
    @cfap_conf_level=0.95
    @cfap_help=false
    @cfap_click()
    @cfap_submit()

    #variables needed for cimean only
    @cimean_nn = 1
    @cimean_me=null
    @cimean_n=null
    @cimean_signa=null
    @cimean_maxn=35
    @cimean_maxme=0.4
    @cimean_maxs=2
    @cimean_conf_level=0.95
    @cimean_help=false
    @cimean_click()
    @cimean_submit()

    #variables needed for OneTGUI only
    @OneTGUI = @app_analysis_powercalc_oneTest
    @OneTGUI_n = 10
    @OneTGUI_nMax = 20
    @OneTGUI_mean = 10
    @OneTGUI_meanMax = 20
    @OneTGUI_mean0 = 10
    @OneTGUI_sigma = 10
    @OneTGUI_sigmaMax = 20
    @OneTGUI_power = 0
    @OneTGUI_alpha = 0.010
    @OneTGUI_variance = 0
    @OneTGUI_t = 0
    @OneTGUI_pvalue = 0
    @OneTGUI_update()


    #variables needed for Pilot only
    @Pilot_n = 1;
    @Pilot_pctUnder=null;
    @Pilot_risk=null;
    @Pilot_df=null;
    @Pilot_maxpctUnder=30;
    @Pilot_maxrisk=0.114;
    @Pilot_maxdf=120;
    @Pilot_help = false;
    @Pilot_click()
    @Pilot_submit()

    #variables needed for RsquareGUI only
    @RsquareGUI_n = 1;
    @RsquareGUI_rho2=null;
    @RsquareGUI_n=null;
    @RsquareGUI_preds=null;
    @RsquareGUI_power=null;
    @RsquareGUI_maxrho2=0.14;
    @RsquareGUI_maxn=70;
    @RsquareGUI_maxpreds=1.4;
    @RsquareGUI_maxpower=1;
    @RsquareGUI_first = true;
    @RsquareGUI_help = false;
    @RsquareGUI_click();
    @RsquareGUI_submit();

    #variables needed for SimpleChi2GUI only
    @SimpleChi2GUI_nn = 1
    @SimpleChi2GUI_Power=null;
    @SimpleChi2GUI_n=null;
    @SimpleChi2GUI_maxn=75;
    @SimpleChi2GUI_maxPower=1;
    @SimpleChi2GUI_help = false;
    @SimpleChi2GUI_click();
    @SimpleChi2GUI_submit();

    #variables needed for SimplePoissonGUI only
    @SimplePoissonGUI_nn = 1;
    @SimplePoissonGUI_lambda0=null;
    @SimplePoissonGUI_lambda=null;
    @SimplePoissonGUI_n=null;
    @SimplePoissonGUI_power=null;
    @SimplePoissonGUI_maxlambda0=1.4;
    @SimplePoissonGUI_maxlambda=7;
    @SimplePoissonGUI_maxn=70;
    @SimplePoissonGUI_maxpower=1;
    @SimplePoissonGUI_help=false;
    @SimplePoissonGUI_alt=0;
    @SimplePoissonGUI_click();
    @SimplePoissonGUI_submit();

    @loadData()

    @$scope.$on 'powercalc:updateAlgorithm', (event, data)=>
      @selectedAlgorithm = data
      console.log("algorithms updated:", @selectedAlgorithm)
      @loadData()

   #receive data
    @$scope.$on 'powercalc: onetwoTestdata', (event, data)=>
      @populations = data.populations
      @algorithmService.passDataByName(@selectedAlgorithm, data)
      @twoTestRetrieve()
      @twoTestGraph()

    @$scope.$on 'powercalc:onetwoTestalpha', (event, data)=>
      @algorithmService.passAlphaByName(@selectedAlgorithm, data.alpha_in)
      @twoTestRetrieve()

    @$scope.$on 'powercalc:change_mode', (event, data)=>
      @deployed=data.deploy
      @oneTestRetrieve()
      @twoTestRetrieve()


    @$scope.$on 'powercalc:updateDataPoints', (event, data) =>
      @data = data.dataPoints

  loadData: () ->
    if (@selectedAlgorithm is "Two-sample t test (general case)")
      @twoTestRetrieve()
      return
    else if (@selectedAlgorithm is "One-Sample (or Paired) t Test")
      @oneTestRetrieve()
      return
    else
      return

  update_algo: (evt) ->
    console.log(@selectedAlgorithm)
    @selectedAlgorithm = evt.currentTarget.value
    @msgService.broadcast 'powercalc:updateAlgorithm_back',
      @selectedAlgorithm

  syncData: (dataIn) ->
    @algorithmService.setParamsByName(@selectedAlgorithm, dataIn)
    @twoTestRetrieve()

  syncPower: (dataIn) ->
    @algorithmService.setPowerByName(@selectedAlgorithm, dataIn)
    @twoTestRetrieve()

  reset: () ->
    @brokenCalc = false
    @algorithmService.resetByName(@selectedAlgorithm)
    @twoTestRetrieve()

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

  #cimean function only
  cimean_clk: (evt) ->
    obj = evt.currentTarget
    #console.log(evt.currentTarget.value)
    if obj
      id=obj.id;
      ck=$(obj).prop("checked")
      if ck
        #console.log(evt.currentTarget.value)
        @cimean_submit("1",'isFinite',"1")
      else
        @cimean_submit("1",'isFinite',"")
    return
  cimean_click: () ->
    $( "#sgnui" ).slider(
      value:@cimean_signa
      min: 0,
      max:@cimean_maxs
      range: "min"
      step: 0.0001
      slide: ( event, ui ) =>
        $( "#sgn" ).val( ui.value )
        @cimean_submit('1','sgn',ui.value)
        return
    )
    $( "#sgn" ).val( $( "#sgnui" ).slider( "value" ) )
    $( "#meuia" ).slider(
      value:@cimean_me
      min: 0,
      max: @cimean_maxme
      range: "min"
      step: 0.00005
      slide: ( event, ui ) =>
        $( "#me" ).val( ui.value )
        @cimean_submit('1','me',ui.value)
        return
    )
    $( "#mea" ).val( $( "#meuia" ).slider( "value" ) )
    $( "#nuia" ).slider(
      value:@cimean_n
      min: 0,
      max: @cimean_maxn
      range: "min"
      step: 0.0025
      slide: (event, ui) =>
        $( "#na" ).val( ui.value )
        @cimean_submit('1','n',ui.value)
        return
    )
    $( "#na" ).val( $( "#nuia" ).slider( "value" ) )
    $("#slidera_conf").slider(
      min: 0.80
      max: 0.99
      value: @cimean_conf_level
      orientation: "horizontal"
      range: "min"
      step: 0.01
      slide: (event, ui) =>
        @cimean_conf_level = ui.value
        $('#confa').val ui.value
        @cimean_submit '1', 'conf', ui.value
        return
    )
  cimean_presubmit: (id, key, evt) ->
    value = evt.currentTarget.value
    #console.log(evt.currentTarget.value)
    @cimean_submit(id, key, value)
  cimean_submit: (id, key, value) ->
    b = @powerAnalysis.CImean(id, key, value)
    if b.isFinite == 1
      $('#isFinitea').prop("checked","checked")
      $('#showNa').show();
    else
      $('#isFinitea').prop("checked","")
      $('#showNa').hide()
    #N
    $('#NN').val(b.NN);
    #signa
    $('#sgn').val(b.Sigma)
    #Conf
    $('#confa').prop("value",b.conf)
    #ME
    $('#mea').val(b.ME)
    #n
    $('#na').val(b.n)
    @cimean_signa=b.Sigma
    #check
    @cimean_me=b.ME
    if @cimean_me > @cimean_maxme
      @cimean_maxme=(@cimean_me/0.02+1)*0.02
    @cimean_n=b.n
    if @cimean_n > @cimean_maxn
      @cimean_maxn=(@cimean_n/20+1)*20
    @cimean_conf_level = b.conf
    @cimean_click()
    return
  cimean_changeSlider: (sliderId, evt) ->
    #console.log("changeSlider hit")
    key = evt.target.value
    #console.log(key)
    @cimean_submit '1', sliderId, key
    return
  cimean_show_help: () ->
    #console.log(@cfap_help)
    if (@cimean_help == true)
      $('#cimeanH').val "Show Help"
    else
      $('#cimeanH').val "Hide Help"
    @cimean_help = !@cimean_help;
    return

  #OnePGUI function only
  OnePGUI_click: ->
        $( "#p0ui" ).slider(
            value: @OnePGUI_p0
            min: 0
            max: @OnePGUI_maxp0
            range: "min"
            step: 0.0001
            slide: ( event, ui ) =>
              $( "#p0" ).val( ui.value )
              @OnePGUI_submit('1','p0',ui.value)
              return
          )
        $( "#p0" ).val( $( "#p0ui" ).slider( "value" ) )
        $( "#pui" ).slider(
            value:@OnePGUI_p
            min: 0
            max: @OnePGUI_maxp
            range: "min"
            step: 0.0001
            slide: ( event, ui ) =>
              $( "#p" ).val( ui.value )
              @OnePGUI_submit('1','p',ui.value)
              return
          )
        $( "#p" ).val( $( "#pui" ).slider( "value" ) )
        $( "#ssizeui" ).slider(
            value:@OnePGUI_ssize,
            min: 0,
            max: @OnePGUI_maxssize,
            range: "min",
            step: 0.01,
            slide:( event, ui ) =>
              $( "#ssize" ).val( ui.value );
              @OnePGUI_submit('1','ssize',ui.value);
              return
          )
        $( "#ssize" ).val( $( "#ssizeui" ).slider( "value" ) )
        $( "#powerui" ).slider(
            value:@OnePGUI_power,
            min: 0,
            max: @OnePGUI_maxpower,
            range: "min"
            step: 0.0001,
            slide: ( event, ui ) =>
              #$( "#power" ).val( ui.value );
              @OnePGUI_submit('1','power',ui.value);
              console.log("moving")
              return
          )
        $( "#power" ).val( $( "#powerui" ).slider( "value" ) );
        $("#alphaui").slider(
          min: 0.005
          max: 0.2
          value: @OnePGUI_alpha
          orientation: "horizontal"
          range: "min"
          step: 0.01
          slide: (event, ui) =>
            @OnePGUI_alpha = ui.value
            $('#alpha').val ui.value
            @OnePGUI_submit '1', 'alpha', ui.value
            return
          )
  OnePGUI_clk: (evt) ->
    obj = evt.currentTarget
    if obj
      id=obj.id;
      ck=$(obj).prop("checked")
      if ck
        #console.log(evt.currentTarget.value)
        @OnePGUI_submit("1",id,"1")
      else
        @OnePGUI_submit("1",id,"")
    return
  OnePGUI_presubmit: (id, key, evt) ->
    value = evt.target.value
    #console.log(evt.currentTarget.value)
    @OnePGUI_submit(id, key, value)
  OnePGUI_submit: (id, key, value) ->
    c = @powerAnalysis.OnePGUI_cfap(id, key, value);
    @OnePGUI_altt_value = c.alt
    @OnePGUI_method_value = c.Method
    $("#p0").prop("value",c.p0);
    @OnePGUI_p0=c.p0;
    $("#p").val(c.p);
    @OnePGUI_p=c.p;
    $("#ssize").val(c.n);
    @OnePGUI_ssize=c.n;
    $("#altt").prop("value",@OnePGUI_altt_value);
    $("#alpha").prop("value",c.Alpha);
    if c.Method is 0
      $("#showsize").show();
      $("#size").val(c.sizes);
    else if c.Method is 3
      $("#showsize").show();
      $("#size").val(c.sizes);
    else
      $("#showsize").hide();
    $("#method").prop("value",@OnePGUI_method_value);
    @OnePGUI_power=c.Power;
    @OnePGUI_click();
  OnePGUI_changeSlider: (sliderId, evt) ->
    #console.log("changeSlider hit")
    key = evt.target.value
    @OnePGUI_submit '1', sliderId, key
    return
  OnePGUI_altt_submit: (id, key) ->
    @OnePGUI_submit(id, key, @OnePGUI_altt_value)
    return
  OnePGUI_method_submit: (id, key) ->
    @OnePGUI_submit(id, key, @OnePGUI_method_value)
    return
  OnePGUI_show_help: () ->
    #console.log(@cfap_help)
    if (@OnePGUI_help == true)
      $('#OnePGUIH').val "Show Help"
    else
      $('#OnePGUIH').val "Hide Help"
    @OnePGUI_help = !@OnePGUI_help
    return

  #functions for OneTGUI only
  oneTestRetrieve: () ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @oneTestn = @params.n
    @oneTestnMax = @params.nMax
    @oneTestmean = parseFloat(@params.mean.toPrecision(4))
    @oneTestmean0 = parseFloat(@params.mean0.toPrecision(4))
    @oneTestmeanMax = parseFloat(@params.meanMax.toPrecision(4))
    @oneTestmean0Max = parseFloat(@params.mean0Max.toPrecision(4))
    @oneTestsigma = parseFloat(@params.sigma.toPrecision(4))
    @oneTestsigmaMax = parseFloat(@params.sigmaMax.toPrecision(4))
    @oneTestpower = parseFloat(@params.power.toPrecision(4))
    @oneTestt = parseFloat(@params.t.toPrecision(4))
    @oneTestpvalue = parseFloat(@params.pvl.toPrecision(4))
    @oneTestmode = @params.mode
    @comp_agents = @params.comp
    @oneTestmodes = ["Two Tailed", "One Tailed"]
    @oneTestClick()
    if (@oneTestn is Infinity)
      @brokenCalc = true
      return
    @oneTestGraph()
    return
  oneTestSync: () ->
    @params.n = @oneTestn
    @params.nMax = @oneTestnMax
    @params.mean = @oneTestmean
    @params.mean0 = @oneTestmean0
    @params.meanMax = @oneTestmeanMax
    @params.sigma = @oneTestsigma
    @params.sigmaMax = @oneTestsigmaMax
    @params.power = @oneTestpower
    @params.mode = @oneTestmode
    @syncData(@params)
    return
  oneTestPower: () ->
    @params.power = @oneTestpower
    @params.mode = @oneTestmode
    @syncPower(@params)
    return
  oneTestPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "oneTestpower"
        @oneTestPower()
      else
        @oneTestSync()
    return
  oneTestClick: () ->
    $( "#oneTestSigmaUI" ).slider(
      value: @oneTestsigma,
      min: 0,
      max: @oneTestsigma,
      range: 'min',
      step: 0.001,
      slide: ( event, ui ) =>
        $( "#oneTestSigmaV" ).val( ui.value );
        @oneTestsigma = ui.value
        @oneTestSync
        return
    )
    $( "#oneTestSigmaV" ).val(@oneTestsigma);

    $( "#oneTestNUI" ).slider(
      value: @oneTestn,
      min: 0,
      max: @oneTestnMax,
      range: "min",
      step: 1,
      slide: ( event, ui ) =>
        $( "#oneTestNV" ).val( ui.value );
        @oneTestn = ui.value
        @oneTestSync()
        return
    )
    $( "#oneTestNV" ).val( @oneTestn );

    $( "#oneTestMeanUI" ).slider(
      value: @oneTestmean,
      min: 0,
      max: @oneTestmeanMax,
      range: "min",
      step: 0.001,
      slide: ( event, ui ) =>
        $( "#oneTestMeanV" ).val( ui.value );
        @oneTestmean = ui.value
        @oneTestSync()
        return
    )
    $( "#oneTestMeanV" ).val( @oneTestmean );

    $( "#oneTestMean0UI" ).slider(
      value: @oneTestmean0,
      min: 0,
      max: @oneTestmean0Max,
      range: "min",
      step: 0.001,
      slide: ( event, ui ) =>
        $( "#oneTestmean0V" ).val( ui.value );
        @oneTestmean0 = ui.value
        @oneTestSync()
        return
    )
    $( "#oneTestmean0V" ).val( @oneTestmean0 );

    $( "#oneTestPowerUI" ).slider(
      value: @oneTestpower,
      min: 0.0001,
      max: 0.9999,
      range: "min",
      step: 0.0001,
      slide:  ( event, ui ) =>
        $( "#oneTestPowerV" ).val( ui.value );
        @oneTestpower = ui.value
        @oneTestPower()
        return
    )
    $( "#oneTestPowerV" ).val( @oneTestpower );
    $( "#oneTestTV" ).val( @oneTestt );
    $( "#oneTestPValueV" ).val( @oneTestpvalue );
    # enable or disable slider
    if @deployed is true
      $("#oneTestSigmaUI").slider("disable")
      $('#oneTestSigmaUI').find('.ui-slider-handle').hide();
      $("#oneTestNUI").slider("disable")
      $('#oneTestNUI').find('.ui-slider-handle').hide();
      $("#oneTestPowerUI").slider("disable")
      $('#oneTestPowerUI').find('.ui-slider-handle').hide();
      $("#oneTestMeanUI").slider("disable")
      $('#oneTestMeanUI').find('.ui-slider-handle').hide();
      $("#oneTestNDisp").text("(" + @comp_agents[0] + "): ")
      $("#oneTestSigmaDisp").text("(" + @comp_agents[0] + "): ")
      $("#oneTestMeanDisp").text("(" + @comp_agents[0] + "): ")
    else
      $("#oneTestSigmaUI").slider("enable")
      $('#oneTestSigmaUI').find('.ui-slider-handle').show();
      $("#oneTestNUI").slider("enable")
      $('#oneTestNUI').find('.ui-slider-handle').show();
      $("#oneTestPowerUI").slider("enable")
      $('#oneTestPowerUI').find('.ui-slider-handle').show();
      $("#oneTestMeanUI").slider("enable")
      $('#oneTestMeanUI').find('.ui-slider-handle').show();
      $("#oneTestNDisp").text(": ")
      $("#oneTestSigmaDisp").text(": ")
      $("#oneTestMeanDisp").text(": ")
    return
  oneTestReset: () ->
    @reset()
  oneTestGraph:() ->
    chartData = @algorithmService.getChartData @selectedAlgorithm
    @$timeout => @chartData = chartData,
    5


  

  #functions for Pilot only
  Pilot_click: () ->
    $( "#pctUnderui" ).slider(
      value:@Pilot_pctUnder,
      min: 0,
      max: @Pilot_maxpctUnder,
      range: "min",
      step: 0.0025,
      slide:( event, ui ) =>
        $( "#pctUnder" ).val( ui.value );
        @Pilot_submit('1','pctUnder',ui.value);
        return
    )
    $( "#pctUnder" ).val( $( "#pctUnderui" ).slider( "value" ) );
    $( "#riskui" ).slider(
      value:@Pilot_risk,
      min: 0,
      max: @Pilot_maxrisk,
      range: "min",
      step: 0.00001,
      slide: ( event, ui ) =>
        $( "#risk" ).val( ui.value );
        @Pilot_submit('1','risk',ui.value);
        return
    )
    $( "#risk" ).val( $( "#riskui" ).slider( "value" ) );
    $( "#dfui" ).slider(
      value:@Pilot_df,
      min: 0,
      max: @Pilot_maxdf,
      range: "min",
      step: 0.01,
      slide: ( event, ui ) =>
        console.log "hit"
        $( "#df" ).val( ui.value );
        @Pilot_submit('1','df',ui.value);
        return
    )
    $( "#df" ).val( $( "#dfui" ).slider( "value" ) );
  Pilot_submit: (id, key, value) ->
    d = @powerAnalysis.pilot_handle(id, key, value);
    $("#pctUnder").val(d.pctUnder);
    @Pilot_pctUnder=d.pctUnder;
    $("#risk").prop("value",d.risk);
    @Pilot_risk=d.risk;
    $("#df").val(d.df);
    @Pilot_df=d.df;
    @Pilot_click();
    return
  Pilot_changeSlider: (sliderId, evt) ->
    #console.log("changeSlider hit")
    key = evt.target.value
    @Pilot_submit '1', sliderId, key
    return
  Pilot_show_help: () ->
    #console.log(@cfap_help)
    if (@Pilot_help == true)
      $('#Pilot_H').val "Show Help"
    else
      $('#Pilot_H').val "Hide Help"
    @Pilot_help = !@Pilot_help
    return

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


  #functions for SimpleChi2GUI only
  SimpleChi2GUI_click: () ->
    $( "#nuig" ).slider(
      value:@SimpleChi2GUI_n,
      min: 0,
      max: @SimpleChi2GUI_maxn,
      range: "min",
      step: 0.005,
      slide: ( event, ui ) =>
        $( "#ng" ).val( ui.value );
        @SimpleChi2GUI_submit('1','n',ui.value);
    )
    $( "#ng" ).val( $( "#nuig" ).slider( "value" ) );
    $( "#Poweruig" ).slider(
      value:@SimpleChi2GUI_Power,
      min: 0,
      max: @SimpleChi2GUI_maxPower,
      range: 'min',
      step: 0.0001,
      slide: ( event, ui ) =>
        $( "#Powerg" ).val( ui.value );
        @SimpleChi2GUI_submit('1','Power',ui.value);
    )
    $( "#Powerg" ).val( $( "#Poweruig" ).slider( "value" ) );
  SimpleChi2GUI_clk: (evt) ->
    obj=evt.currentTarget
    if obj
      id=obj.id;
      ck=$(obj).prop("checked");
    if ck
      @SimpleChi2GUI_submit("1",id,"1");
    else
      @SimpleChi2GUI_submit("1",id,"");
  SimpleChi2GUI_submit: (id, key, value) ->
    d = @powerAnalysis.SimpleChi2GUI_handle(id, key, value);
    $("#proChi2g").prop("value",d.proChi2);
    $("#proNg").prop("value",d.proN);
    $("#dfg").prop("value",d.df);
    $("#Alphag").prop("value",d.Alpha);
    $("#ng").val(d.n);
    $("#Powerg").val(d.Power);
    @SimpleChi2GUI_Power=d.Power;
    if @SimpleChi2GUI_Power > @SimpleChi2GUI_maxPower
      @SimpleChi2GUI_maxPower= (@SimpleChi2GUI_Power / 0.02 + 1) * 0.02;
    @SimpleChi2GUI_n = d.n;
    if @SimpleChi2GUI_n > @SimpleChi2GUI_maxn
      @SimpleChi2GUI_maxn = (@SimpleChi2GUI_n / 20 + 1) * 20;
    @SimpleChi2GUI_click();
  SimpleChi2GUI_valiad: (evt) ->
    id = evt.target.name
    data = evt.target.value
    r=/^\d+(\.\d+)?$/;
    if r.test(data)
      @SimpleChi2GUI_submit('1',id,data);
      return true;
    else
      return true;
  SimpleChi2GUI_changeSlider: (sliderId, evt) ->
    #console.log("changeSlider hit")
    key = evt.target.value
    @SimpleChi2GUI_submit '1', sliderId, key
    return
  SimpleChi2GUI_show_help: () ->
    #console.log(@cfap_help)
    if @SimpleChi2GUI_help is true
      $('#SimpleChi2GUI_H').val "Show Help"
    else
      $('#SimpleChi2GUI_H').val "Hide Help"
    @SimpleChi2GUI_help = !@SimpleChi2GUI_help
    return

  #functions for SimplePoissonGUI only
  SimplePoissonGUI_click: () ->
    $( "#lambda0uih" ).slider(
      value: @SimplePoissonGUI_lambda0,
      min: 0,
      max: @SimplePoissonGUI_maxlambda0,
      range: "min",
      step: 0.0001,
      slide: ( event, ui ) =>
        $( "#lambda0f" ).val( ui.value );
        @SimplePoissonGUI_submit('1','lambda0',ui.value);
        return
    )
    $( "#lambda0h" ).val( $( "#lambda0uih" ).slider( "value" ) );
    $( "#lambdauih" ).slider(
      value:@SimplePoissonGUI_lambda,
      min: 0,
      max: @SimplePoissonGUI_maxlambda,
      range: "min",
      step: 0.0005,
      slide: ( event, ui ) =>
        $( "#lambdah" ).val( ui.value );
        @SimplePoissonGUI_submit('1','lambda',ui.value);
        return
    )
    $( "#lambdah" ).val( $( "#lambdauih" ).slider( "value" ) );
    $( "#nuih" ).slider(
      value:@SimplePoissonGUI_n,
      min: 0,
      max: @SimplePoissonGUI_maxn,
      range: "min",
      step: 0.01,
      slide: ( event, ui ) =>
        $( "#nh" ).val( ui.value );
        @SimplePoissonGUI_submit('1','n',ui.value);
        return
    )
    $("#nh").val($("#nuih").slider("value"));
    $( "#poweruih" ).slider(
      value:@SimplePoissonGUI_power,
      min: 0,
      max: @SimplePoissonGUI_maxpower,
      range: "min",
      step: 0.0001,
      slide: ( event, ui ) =>
        #console.log('hit1');
        $( "#powerh" ).val( ui.value );
        @SimplePoissonGUI_submit('1','power',ui.value);
        return
    )
    $("#powerh").val($("#poweruih").slider("value"));
  SimplePoissonGUI_clk: (evt) ->
    obj=evt.currentTarget
    if obj
      id=obj.id;
      ck=$(obj).prop("checked");
    if ck
      @SimplePoissonGUI_submit("1",id,"1");
    else
      @SimplePoissonGUI_submit("1",id,"");
    return
  SimplePoissonGUI_submit: (id, key, value) ->
    d = @powerAnalysis.SimplePoissonGUI_handle(id, key, value);
    $("#lambda0h").val(d.lambda0);
    @SimplePoissonGUI_lambda0 = d.lambda0;
    $("#lambdah").val(d.lambda);
    @SimplePoissonGUI_lambda = d.lambda;
    $("#alphah").prop("value",d.alpha);
    $("#powerh").val(d.power);
    @SimplePoissonGUI_power = d.power;
    $("#sizeh").html(d.size);
    $("#lowerh").html(d.lower);
    $("#upperh").html(d.upper);
    $("#nh").val(d.n);
    @SimplePoissonGUI_n=d.n;
    $("#alth").prop("value",d.alt);
    @SimplePoissonGUI_click();
    return
  SimplePoissonGUI_valiad: (evt) ->
    id = evt.target.name
    data = evt.target.value
    r=/^\d+(\.\d+)?$/;
    if r.test(data)
      @SimplePoissonGUI_submit('1',id,data);
      return
    else
      return false;
  SimplePoissonGUI_opt_submit: (id, key) ->
    @SimplePoissonGUI_submit(id, key, @SimplePoissonGUI_alt)
    return
  SimplePoissonGUI_changeSlider: (sliderId, evt) ->
    #console.log("changeSlider hit")
    key = evt.target.value
    @SimplePoissonGUI_submit '1', sliderId, key
    return
  SimplePoissonGUI_show_help: () ->
    #console.log(@cfap_help)
    if @SimplePoissonGUI_help is true
      $('#SimplePoissonGUI_H').val "Show Help"
    else
      $('#SimplePoissonGUI_H').val "Hide Help"
    @SimplePoissonGUI_help = !@SimplePoissonGUI_help
    return

  twoTestRetrieve: () ->
    @params = @algorithmService.getParamsByName(@selectedAlgorithm)
    @twoTestn1 = @params.n1
    @twoTestn2 = @params.n2
    @twoTestmaxn = @params.nMax
    @twoTestmean1 = parseFloat(@params.mean1.toPrecision(4))
    @twoTestmean2 = parseFloat(@params.mean2.toPrecision(4))
    @twoTestmeanMax = parseFloat(@params.meanMax.toPrecision(4))
    @twoTestsigma1 = parseFloat(@params.sigma1.toPrecision(4))
    @twoTestsigma2 = parseFloat(@params.sigma2.toPrecision(4))
    @twoTestsigmaMax = parseFloat(@params.sigmaMax.toPrecision(4))
    @twoTestpower = parseFloat(@params.power.toPrecision(4))
    @twoTestt = parseFloat(@params.t.toPrecision(4))
    @twoTestpvalue = parseFloat(@params.pvl.toPrecision(4))
    @twoTestmode = @params.mode
    @comp_agents = @params.comp
    @twoTestmodes = ["Two Tailed", "One Tailed"]
    @twoTestClick()
    if (@twoTestn2 is Infinity) or (@twoTestn1 is Infinity)
      @brokenCalc = true
      return
    @twoTestGraph()
    return
  twoTestSync: () ->
    @params.n1 = @twoTestn1
    @params.n2 = @twoTestn2
    @params.nMax = @twoTestmaxn
    @params.mean1 = @twoTestmean1
    @params.mean2 = @twoTestmean2
    @params.meanMax = @twoTestmeanMax
    @params.sigma1 = @twoTestsigma1
    @params.sigma2 = @twoTestsigma2
    @params.sigmaMax = @twoTestsigmaMax
    @params.power = @twoTestpower
    @params.mode = @twoTestmode
    @syncData(@params)
    return
  twoTestPower: () ->
    @params.power = @twoTestpower
    @params.mode = @twoTestmode
    @syncPower(@params)
    return
  twoTestPress: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      if name is "twoTestpower"
        @twoTestPower()
        return
      else
        @twoTestSync()
        return
  twoTestClick: () ->
    $( "#twoTestsigma1ui" ).slider(
      value: @twoTestsigma1,
      min: 0,
      max: @twoTestsigmaMax,
      range: 'min',
      step: 0.01,
      slide: ( event, ui ) =>
        $( "#twoTestsigma1_v" ).val( ui.value );
        @twoTestsigma1 = ui.value
        @twoTestSync()
        return
    )
    $( "#twoTestsigma1_v" ).val( @twoTestsigma1);
    $( "#twoTestsigma2ui" ).slider(
      value:@twoTestsigma2,
      min: 0,
      max: @twoTestsigmaMax,
      range: "min",
      step: 0.01,
      slide: ( event, ui ) =>
        $( "#twoTestsigma2_v" ).val( ui.value );
        @twoTestsigma2 = ui.value
        @twoTestSync()
        return
    )
    $( "#twoTestsigma2_v" ).val(@twoTestsigma2);

    $( "#twoTestn1ui" ).slider(
      value:@twoTestn1,
      min: 0,
      max: @twoTestmaxn,
      range: "min",
      step: 1,
      slide: ( event, ui ) =>
        $( "#twoTestn1_v" ).val( ui.value );
        @twoTestn1 = ui.value
        @twoTestSync()
        return
    )
    $( "#twoTestn1_v" ).val( @twoTestn1 );
    $( "#twoTestn2ui" ).slider(
      value:@twoTestn2,
      min: 0,
      max: @twoTestmaxn,
      range: "min",
      step: 1,
      slide: ( event, ui ) =>
        $( "#twoTestn2_v" ).val( ui.value );
        @twoTestn2 = ui.value
        @twoTestSync()
        return
    )
    $( "#twoTestn2_v" ).val( @twoTestn2 );

    $( "#twoTestmean1ui" ).slider(
      value:@twoTestmean1,
      min: 0,
      max: @twoTestmeanMax,
      range: "min",
      step: 0.01,
      slide: ( event, ui ) =>
        $( "#twoTestmean1_v" ).val( ui.value );
        @twoTestmean1 = ui.value
        @twoTestSync()
        return
    )
    $( "#twoTestmean1_v" ).val( @twoTestmean1);
    $( "#twoTestmean2ui" ).slider(
      value:@twoTestmean2,
      min: 0,
      max: @twoTestmeanMax,
      range: "min",
      step: 0.01,
      slide: ( event, ui ) =>
        $( "#twoTestmean2_v" ).val( ui.value );
        @twoTestmean2 = ui.value
        @twoTestSync()
        return
    )
    $( "#twoTestmean2_v" ).val( @twoTestmean2);
    $( "#twoTestpowerui" ).slider(
      value:@twoTestpower,
      min: 0.0001,
      max: 0.9999,
      range: "min",
      step: 0.0001,
      slide:  ( event, ui ) =>
        $( "#twoTestpower_v" ).val( ui.value );
        @twoTestpower = ui.value
        @twoTestPower()
        return
    )
    $( "#twoTestpower_v" ).val( @twoTestpower);
    $( "#twoTestt_v" ).val( @twoTestt );
    $( "#twoTestpvalue_v" ).val( @twoTestpvalue );
    # enable or disable slider
    if @deployed is true
      $("#twoTestsigma1ui").slider("disable")
      $('#twoTestsigma1ui').find('.ui-slider-handle').hide();
      $("#twoTestsigma2ui").slider("disable")
      $('#twoTestsigma2ui').find('.ui-slider-handle').hide();
      $("#twoTestn1ui").slider("disable")
      $('#twoTestn1ui').find('.ui-slider-handle').hide();
      $("#twoTestn2ui").slider("disable")
      $('#twoTestn2ui').find('.ui-slider-handle').hide();
      $("#twoTestpowerui").slider("disable")
      $('#twoTestpowerui').find('.ui-slider-handle').hide();
      $("#twoTestmean1ui").slider("disable")
      $('#twoTestmean1ui').find('.ui-slider-handle').hide();
      $("#twoTestmean2ui").slider("disable")
      $('#twoTestmean2ui').find('.ui-slider-handle').hide();
      $("#psigma1i").text("(" + @comp_agents[0] + "): ")
      $("#psigma2i").text("(" + @comp_agents[1] + "): ")
      $("#pn1i").text("(" + @comp_agents[0] + "): ")
      $("#pn2i").text("(" + @comp_agents[1] + "): ")
      $("#pmean1i").text("(" + @comp_agents[0] + "): ")
      $("#pmean2i").text("(" + @comp_agents[1] + "): ")
    else
      $("#twoTestsigma1ui").slider("enable")
      $('#twoTestsigma1ui').find('.ui-slider-handle').show();
      $("#twoTestsigma2ui").slider("enable")
      $('#twoTestsigma2ui').find('.ui-slider-handle').show();
      $("#twoTestn1ui").slider("enable")
      $('#twoTestn1ui').find('.ui-slider-handle').show();
      $("#twoTestn2ui").slider("enable")
      $('#twoTestn2ui').find('.ui-slider-handle').show();
      $("#twoTestpowerui").slider("enable")
      $('#twoTestpowerui').find('.ui-slider-handle').show();
      $("#twoTestmean1ui").slider("enable")
      $('#twoTestmean1ui').find('.ui-slider-handle').show();
      $("#twoTestmean2ui").slider("enable")
      $('#twoTestmean2ui').find('.ui-slider-handle').show();
      $("#psigma1i").text("1: ")
      $("#psigma2i").text("2: ")
      $("#pn1i").text("1: ")
      $("#pn2i").text("2: ")
      $("#pmean1i").text("1: ")
      $("#pmean2i").text("2: ")
  twoTestReset: () ->
    @reset()
  twoTestGraph:() ->
    chartData = @algorithmService.getChartData @selectedAlgorithm
    @$timeout => @chartData = chartData,
    5
