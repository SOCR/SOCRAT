'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcMainCtrl extends BaseCtrl
  @inject 'app_analysis_powercalc_msgService',
  'app_analysis_powercalc_TwoTGUI',
  '$timeout',
  '$scope'

  initialize: ->
    console.log("mainArea initialized")
    @powerAnalysis = require 'powercalc'
    @distribution = require 'distributome'
    @jstat = require 'jstat'
    @msgService = @app_analysis_powercalc_msgService
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

    @$scope.$on 'powercalc:updateDataPoints', (event, data) =>
#      @showresults = off if @showresults is on
      # safe enforce $scope.$digest to activate directive watchers
      @$timeout => @updateChartData(data)

    @$scope.$on 'powercalc:updateDataType', (event, dataType) =>
      @dataType = dataType

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

    #variables needed for OnePGUI only
    @OnePGUI_nn = 1
    @OnePGUI_p0=null
    @OnePGUI_p=null
    @OnePGUI_ssize=null
    @OnePGUI_power=null
    @OnePGUI_maxp0=1.0
    @OnePGUI_maxp=1.0
    @OnePGUI_maxssize=77
    @OnePGUI_maxpower=1.0
    @OnePGUI_alpha=0.02
    @OnePGUI_help=false
    @OnePGUI_altt_value = 1
    @OnePGUI_method_value = 1
    @OnePGUI_click()
    @OnePGUI_submit()

    #variables needed for OneTGUI only
    @OneTGUI_nn = 1
    @OneTGUI_sigma=null;
    @OneTGUI_diff=null;
    @OneTGUI_n=null;
    @OneTGUI_power=null;
    @OneTGUI_maxsigma=1.4;
    @OneTGUI_maxdiff=0.7;
    @OneTGUI_maxn=35;
    @OneTGUI_maxpower=1;
    @OneTGUI_first = true;
    @OneTGUI_help = false;
    @OneTGUI_alpha = 0.02
    @OneTGUI_optd = 0;
    @OneTGUI_optd_submit()
    @OneTGUI_click()
    @OneTGUI_submit()

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

    #variables needed for TwoTGUI only
    @TwoTGUI = @app_analysis_powercalc_TwoTGUI
    @TwoTGUI_n1 = 10
    @TwoTGUI_n2 = 10
    @TwoTGUI_maxn1 = 20
    @TwoTGUI_maxn2 = 20
    @TwoTGUI_maxn = 20
    @TwoTGUI_mean1 = 10
    @TwoTGUI_mean2 = 10
    @TwoTGUI_meanMax1 = 20
    @TwoTGUI_meanMax2 = 20
    @TwoTGUI_meanMax = 20
    @TwoTGUI_sigma1 = 0.5
    @TwoTGUI_sigma2 = 0.5
    @TwoTGUI_sigmaMax1 = 1
    @TwoTGUI_sigmaMax2 = 1
    @TwoTGUI_sigmaMax = 1
    @TwoTGUI_alpha = 0.010
    @TwoTGUI_power = 0
    @TwoTGUI_powerMax = 1 
    # @TwoTGUI_nn = 2;
    # @TwoTGUI_sigma1=0.1;
    # @TwoTGUI_sigma2=0.1;
    # @TwoTGUI_n1=10;
    # @TwoTGUI_n2=10;
    # @TwoTGUI_diff=0.5;
    # @TwoTGUI_power=0;
    # @TwoTGUI_maxsigma1=1.4;
    # @TwoTGUI_maxsigma2=1.4;
    # @TwoTGUI_maxn1=35;
    # @TwoTGUI_maxn2=35;
    # @TwoTGUI_maxdiff=1.0;
    # @TwoTGUI_maxpower=1;
    # @TwoTGUI_maxdf = 100;
    # @TwoTGUI_help=false;
    # @TwoTGUI_alloc_value=0;
    # @TwoTGUI_opt_value=0;
    # @TwoTGUI_alpha=0.010;
    # @TwoTGUI_threshold=1;
    # @TwoTGUI_df=1;
    # @TwoTGUI_tscore = 0;
    # @TwoTGUI_pvalue = 0;
    @TwoTGUI_update()
    
    @$scope.$on 'powercalc:updateAlgorithm', (event, data)=>
      @selectedAlgorithm = data
      console.log("algorithms updated:", @selectedAlgorithm)

    @$scope.$on 'powercalc:TwoTGUI_alpha', (event, data)=>
      @TwoTGUI_alpha = data.alpha_in
      @TwoTGUI_update()

    @$scope.$on 'powercalc:TwoTGUI_data', (event, data)=>
      @populations = data.populations
      if (data.chosenCol.length is 2)
        @comp_agents = data.chosenCol
      else
        @comp_agents = data.chosenVar
      @drive_data()

    @$scope.$on 'powercalc:change_mode', (event, data)=>
      @deployed=data.deploy
      d3.select("#Two_TGUI_graph").select("svg").remove()
      @TwoTGUI_update()
      if !@deployed
        $("#psigma1i").text("1: ")
        $("#psigma2i").text("2: ")
        $("#pn1i").text("1: ")
        $("#pn2i").text("2: ")
        $("#pmean1i").text("1: ")
        $("#pmean2i").text("2: ")

    @$scope.$on 'powercalc:updateDataPoints', (event, data) =>
      @data = data.dataPoints


  drive_data: () ->
    if (@selectedAlgorithm is "Two-sample t test (general case)")
      console.log "hit"

      # check population length
      if (Object.keys(@populations).length isnt 2)
        window.alert("main: population length")
        return

      @TwoTGUI_receive_data()
      @TwoTGUI_graph()



    

  #global
  updateChartData: (data) ->
    if data.dataPoints?
      @dataPoints = data.dataPoints
    @means = data.means
    @assignments = data.labels

  update_algo: (evt) ->
    console.log(@selectedAlgorithm)
    @selectedAlgorithm = evt.currentTarget.value
    @msgService.broadcast 'powercalc:updateAlgorithm_back',
      @selectedAlgorithm

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
  OneTGUI_click: () ->
    if @OneTGUI_first
      $( "#sigmauid" ).slider(
        value:@OneTGUI_sigma,
        min: 0,
        max: @OneTGUI_maxsigma,
        range: "min", 
        step: 0.0001,
        slide: ( event, ui ) =>
          $( "#sigmad" ).val( ui.value );
          @OneTGUI_submit('1','sigma',ui.value);
          return
      )           
      $( "#diffuid" ).slider(
        value:@OneTGUI_diff,
        min: 0,
        max: @OneTGUI_maxdiff,
        range: "min", 
        step: 0.00005,
        slide: ( event, ui ) =>
          $( "#diffd" ).val( ui.value );
          @OneTGUI_submit('1','diff',ui.value);
          return
      )           
      $( "#nuid" ).slider(
        value:@OneTGUI_n,
        min: 0,
        max: @OneTGUI_maxn,
        range: "min", 
        step: 0.0025,
        slide: ( event, ui ) =>
          $( "#nd" ).val( ui.value );
          @OneTGUI_submit('1','n',ui.value);
          return
      )
      $( "#poweruid" ).slider(
        value:@OneTGUI_power,
        min: 0,
        max: @OneTGUI_maxpower,
        range: "min", 
        step: 0.0001,
        slide: ( event, ui ) =>
          #$( "#powerd" ).val( ui.value );
          @OneTGUI_submit('1','power',ui.value);
          return
      )
      $("#alphauid").slider(
          min: 0.005
          max: 0.2
          value: @OneTGUI_alpha
          orientation: "horizontal"
          range: "min"
          step: 0.01
          slide: (event, ui) =>
            @OneTGUI_alpha = ui.value
            $('#alphad').val ui.value
            @OneTGUI_submit '1', 'alpha', ui.value
            return
          )
      @OneTGUI_first = false;
    $( "#sigmauid" ).slider('value', @OneTGUI_sigma);
    $( "#diffuid" ).slider('value',@OneTGUI_diff);
    $( "#nuid" ).slider('value',@OneTGUI_n);
    $( "#poweruid" ).slider('value',@OneTGUI_power);  
    $( "#sigmad" ).val( $( "#sigmauid" ).slider( "value" ) );
    $( "#diffd" ).val( $( "#diffuid" ).slider( "value" ) );
    $( "#nd" ).val( $( "#nuid" ).slider( "value" ) );
    $( "#powerd" ).val( $( "#poweruid" ).slider( "value" ) );
  OneTGUI_clk: (evt) ->
    obj = evt.currentTarget
    if obj
      id=obj.id;
      ck=$(obj).prop("checked")
      console.log(ck)
      if ck
        #console.log(evt.currentTarget.value)
        @OneTGUI_submit("1",id,"1")
      else
        @OneTGUI_submit("1",id,"")
    return  
  OneTGUI_optd_submit: (id, key) ->
    @OneTGUI_submit(id, key, @OneTGUI_optd)
    return
  OneTGUI_submit: (id, key, value) ->
    d = @powerAnalysis.handle(id, key, value)
    @OneTGUI_sigma=d.sigma
    $("#sigmad").prop("value",d.sigma)
    @OneTGUI_diff=d.diff;
    $("#diffd").prop("value",d.diff);
    @OneTGUI_n=d.n;
    $("#nd").val(d.n);
    @OneTGUI_power=d.power;
    #$("#powerd").prop("value",d.power);
    $("#optd").prop("value",d.opt);
    $("#alphad").prop("value",d.alpha);
    if d.tt is 1
      $("#tt").prop("checked","checked");
    else
      $("#tt").prop("checked","");
    @OneTGUI_click();                    
  OneTGUI_show_help: () ->
    #console.log(@cfap_help)
    if (@OneTGUI_help == true)
      $('#OneTGUI_H').val "Show Help"
    else
      $('#OnePGUI_H').val "Hide Help"
    @OneTGUI_help = !@OneTGUI_help
    return
  OneTGUI_changeSlider: (sliderId, evt) ->
    #console.log("changeSlider hit")
    key = evt.target.value
    @OneTGUI_submit '1', sliderId, key
    return

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

  #functions for TwoTGUI only @comp_agents
  TwoTGUI_receive_data: () ->
    item1 = Object.keys(@populations)[0]
    item2 = Object.keys(@populations)[1]
    # extract name of two sample
    $("#psigma1i").text("(" + @comp_agents[0] + "): ")
    $("#psigma2i").text("(" + @comp_agents[1] + "): ")
    $("#pn1i").text("(" + @comp_agents[0] + "): ")
    $("#pn2i").text("(" + @comp_agents[1] + "): ")
    $("#pmean1i").text("(" + @comp_agents[0] + "): ")
    $("#pmean2i").text("(" + @comp_agents[1] + "): ")

    # update all Two_TGUI variables
    @TwoTGUI_n1 = @populations[item1].length
    @TwoTGUI_n2 = @populations[item2].length
    @TwoTGUI_mean1 = @TwoTGUI.getMean(@TwoTGUI.getSum(@populations[item1]),@populations[item1].length)
    @TwoTGUI_mean2 = @TwoTGUI.getMean(@TwoTGUI.getSum(@populations[item2]),@populations[item2].length)
    TwoTGUI_variance1 = @TwoTGUI.getVariance(@populations[item1], @TwoTGUI_mean1)
    TwoTGUI_variance2 = @TwoTGUI.getVariance(@populations[item2], @TwoTGUI_mean2)
    @TwoTGUI_sigma1 = Math.sqrt(TwoTGUI_variance1)
    @TwoTGUI_sigma2 = Math.sqrt(TwoTGUI_variance2)

    @TwoTGUI_checkRange()
    @TwoTGUI_update()

  TwoTGUI_checkRange:() ->
    @TwoTGUI_maxn1 = Math.max(@TwoTGUI_n1, @TwoTGUI_maxn1)
    @TwoTGUI_maxn2 = Math.max(@TwoTGUI_n2, @TwoTGUI_maxn2)
    @TwoTGUI_maxn = Math.max(@TwoTGUI_maxn1, @TwoTGUI_maxn2)
    @TwoTGUI_meanMax1 = Math.max(@TwoTGUI_mean1, @TwoTGUI_meanMax1)
    @TwoTGUI_meanMax2 = Math.max(@TwoTGUI_mean2, @TwoTGUI_meanMax2)
    @TwoTGUI_meanMax = Math.max(@TwoTGUI_meanMax1, @TwoTGUI_meanMax2)
    @TwoTGUI_sigmaMax1 = Math.max(@TwoTGUI_sigma1, @TwoTGUI_sigmaMax1)
    @TwoTGUI_sigmaMax2 = Math.max(@TwoTGUI_sigma2, @TwoTGUI_sigmaMax2)
    @TwoTGUI_sigmaMax = Math.max(@TwoTGUI_sigmaMax1, @TwoTGUI_sigmaMax2)

  TwoTGUI_click: () ->
    $( "#TwoTGUI_sigma1ui" ).slider(
      value: @TwoTGUI_sigma1,
      min: 0,
      max: @TwoTGUI_sigmaMax,
      range: 'min', 
      step: 0.01,
      slide: ( event, ui ) =>
        $( "#TwoTGUI_sigma1_v" ).val( ui.value );
        @TwoTGUI_sigma1 = ui.value
        @TwoTGUI_update()
        return
    )
    $( "#TwoTGUI_sigma1_v" ).val( @TwoTGUI_sigma1.toFixed(3));
    $( "#TwoTGUI_sigma2ui" ).slider(
      value:@TwoTGUI_sigma2,
      min: 0,
      max: @TwoTGUI_sigmaMax,
      range: "min", 
      step: 0.01,
      slide: ( event, ui ) =>
        $( "#TwoTGUI_sigma2_v" ).val( ui.value );
        @TwoTGUI_sigma2 = ui.value
        @TwoTGUI_update()
        return
    )          
    $( "#TwoTGUI_sigma2_v" ).val(@TwoTGUI_sigma2.toFixed(3));

    $( "#TwoTGUI_n1ui" ).slider(
      value:@TwoTGUI_n1,
      min: 0,
      max: @TwoTGUI_maxn,
      range: "min", 
      step: 1,
      slide: ( event, ui ) =>
        $( "#TwoTGUI_n1_v" ).val( ui.value );
        @TwoTGUI_n1 = ui.value
        @TwoTGUI_update()
        return
    )          
    $( "#TwoTGUI_n1_v" ).val( @TwoTGUI_n1 );
    $( "#TwoTGUI_n2ui" ).slider(
      value:@TwoTGUI_n2,
      min: 0,
      max: @TwoTGUI_maxn,
      range: "min", 
      step: 1,
      slide: ( event, ui ) =>
        $( "#TwoTGUI_n2_v" ).val( ui.value );
        @TwoTGUI_n2 = ui.value
        @TwoTGUI_update()
        return
    )        
    $( "#TwoTGUI_n2_v" ).val( @TwoTGUI_n2 );

    $( "#TwoTGUI_mean1ui" ).slider(
      value:@TwoTGUI_mean1,
      min: 0,
      max: @TwoTGUI_meanMax,
      range: "min", 
      step: 0.01,
      slide: ( event, ui ) =>
        $( "#TwoTGUI_mean1_v" ).val( ui.value );
        @TwoTGUI_mean1 = ui.value
        @TwoTGUI_update()
        return
    )   
    $( "#TwoTGUI_mean1_v" ).val( @TwoTGUI_mean1.toFixed(3) );       
    $( "#TwoTGUI_mean2ui" ).slider(
      value:@TwoTGUI_mean2,
      min: 0,
      max: @TwoTGUI_meanMax,
      range: "min", 
      step: 0.01,
      slide: ( event, ui ) =>
        $( "#TwoTGUI_mean2_v" ).val( ui.value );
        @TwoTGUI_mean2 = ui.value
        @TwoTGUI_update()
        return
    )        
    $( "#TwoTGUI_mean2_v" ).val( @TwoTGUI_mean2.toFixed(3) );
    $( "#TwoTGUI_powerui" ).slider(
      value:@TwoTGUI_power,
      min: 0.0001,
      max: 0.9999,
      range: "min", 
      step: 0.0001,
      slide:  ( event, ui ) =>
        $( "#TwoTGUI_power_v" ).val( ui.value );
        @TwoTGUI_power = ui.value
        @TwoTGUI_powerTon()
        return
    )         
    $( "#TwoTGUI_power_v" ).val( @TwoTGUI_power.toFixed(3) );
    # enable or disable slider
    
    if @deployed is true
      $("#TwoTGUI_sigma1ui").slider("disable")
      $('#TwoTGUI_sigma1ui').find('.ui-slider-handle').hide();
      $("#TwoTGUI_sigma2ui").slider("disable")
      $('#TwoTGUI_sigma2ui').find('.ui-slider-handle').hide();
      $("#TwoTGUI_n1ui").slider("disable")
      $('#TwoTGUI_n1ui').find('.ui-slider-handle').hide();
      $("#TwoTGUI_n2ui").slider("disable")
      $('#TwoTGUI_n2ui').find('.ui-slider-handle').hide();
      $("#TwoTGUI_powerui").slider("disable")
      $('#TwoTGUI_powerui').find('.ui-slider-handle').hide();
      $("#TwoTGUI_mean1ui").slider("disable")
      $('#TwoTGUI_mean1ui').find('.ui-slider-handle').hide();
      $("#TwoTGUI_mean2ui").slider("disable")
      $('#TwoTGUI_mean2ui').find('.ui-slider-handle').hide();
    else 
      $("#TwoTGUI_sigma1ui").slider("enable")
      $('#TwoTGUI_sigma1ui').find('.ui-slider-handle').show();
      $("#TwoTGUI_sigma2ui").slider("enable")
      $('#TwoTGUI_sigma2ui').find('.ui-slider-handle').show();
      $("#TwoTGUI_n1ui").slider("enable")
      $('#TwoTGUI_n1ui').find('.ui-slider-handle').show();
      $("#TwoTGUI_n2ui").slider("enable")
      $('#TwoTGUI_n2ui').find('.ui-slider-handle').show();
      $("#TwoTGUI_powerui").slider("enable")
      $('#TwoTGUI_powerui').find('.ui-slider-handle').show();
      $("#TwoTGUI_mean1ui").slider("enable")
      $('#TwoTGUI_mean1ui').find('.ui-slider-handle').show();
      $("#TwoTGUI_mean2ui").slider("enable")
      $('#TwoTGUI_mean2ui').find('.ui-slider-handle').show();
  TwoTGUI_update: () ->
    kappa = @TwoTGUI_n1 / @TwoTGUI_n2
    z = (@TwoTGUI_mean1 - @TwoTGUI_mean2) / (Math.sqrt(Math.pow(@TwoTGUI_sigma1,2) + Math.pow(@TwoTGUI_sigma2,2)) * Math.sqrt((1+(1 / kappa)) / @TwoTGUI_n2))
    @TwoTGUI_power = @distribution.pnorm(z-@distribution.qnorm(1-@TwoTGUI_alpha/2))+@distribution.pnorm(-z-@distribution.qnorm(1-@TwoTGUI_alpha/2))
    @TwoTGUI_checkRange()
    @TwoTGUI_click()
    @TwoTGUI_graph()
  TwoTGUI_powerTon: () ->
    kappa = 1
    stdv = Math.sqrt(Math.pow(@TwoTGUI_sigma1,2) + Math.pow(@TwoTGUI_sigma2,2))
    @TwoTGUI_n2 = (1 + 1 / kappa)*Math.pow(stdv*(@distribution.qnorm(1-@TwoTGUI_alpha / 2)+@distribution.qnorm(1-(1-@TwoTGUI_power)))/(@TwoTGUI_mean1-@TwoTGUI_mean2),2)
    @TwoTGUI_n2 = Math.ceil(@TwoTGUI_n2)
    @TwoTGUI_maxn2 = Math.max(@TwoTGUI_maxn2, @TwoTGUI_n2)
    @TwoTGUI_checkRange()
    @TwoTGUI_click()
    @TwoTGUI_graph()
  TwoTGUI_graph:() ->
    @TwoTGUI.drawNormalCurve(@TwoTGUI_mean1, Math.pow(@TwoTGUI_sigma1, 2), @TwoTGUI_sigma1, @TwoTGUI_mean2, Math.pow(@TwoTGUI_sigma2, 2), @TwoTGUI_sigma2, @TwoTGUI_alpha);
    # $("#display1").text("("+mean1.toFixed(1)+", "+sigma1.toFixed(2)+")")
    # $("#display2").text("("+mean2.toFixed(1)+", "+sigma2.toFixed(2)+")")
    # $("#display_critical").text("Critical t: "+crit.toFixed(1))
    if @deployed
      $("#display_legend1").text(@comp_agents[0])
      $("#display_legend2").text(@comp_agents[1])
      $("#display_legend1").css("background-color","aquamarine")
      $("#display_legend2").css("background-color","chocolate")
    else
      $("#display_legend1").text("Sample1")
      $("#display_legend2").text("Sample2")
      $("#display_legend1").css("background-color","aquamarine")
      $("#display_legend2").css("background-color","chocolate")
  TwoTGUI_changeValue: (evt) ->
    name = evt.target.name
    val = evt.target.value
    key = evt.which or evt.keyCode
    if name is "TwoTGUI_n1"
      @TwoTGUI_n1 = parseFloat(val)
    if name is "TwoTGUI_n2"
      @TwoTGUI_n2 = parseFloat(val)
    if name is "TwoTGUI_mean1"
      @TwoTGUI_mean1 = parseFloat(val)
    if name is "TwoTGUI_mean2"
      @TwoTGUI_mean2 = parseFloat(val)
    if name is "TwoTGUI_sigma1"
      @TwoTGUI_sigma1 = parseFloat(val)
    if name is "TwoTGUI_sigma2"
      @TwoTGUI_sigma2 = parseFloat(val)
    if name is "TwoTGUI_power"
      @TwoTGUI_power = parseFloat(val)
    if key is 13
      if name is "TwoTGUI_power"
        @TwoTGUI_powerTon()
        return
      @TwoTGUI_update()
      return
  TwoTGUI_show_help: () ->
    if @TwoTGUI_help is true
      $('#TwoTGUI_H').val "Show Help"
    else
      $('#TwoTGUI_H').val "Hide Help"
    @TwoTGUI_help = !@TwoTGUI_help
    return

  tprob: ($n, $x) ->
    if $n <= 0 or Math.abs($n) - Math.abs(@integer($n)) != 0
      throw 'Invalid n: $n\n'
      ### degree of freedom ###
    @precision_string @_subtprob($n - 0, $x - 0)

  integer: ($i) ->
    if $i > 0
      Math.floor $i
    else
      Math.ceil $i

  precision_string: ($x) ->
    if $x
      @round_to_precision $x, @precision($x)
    else
      '0'

  round_to_precision: ($x, $p) ->
    $x = $x * 10 ** $p
    $x = Math.round($x)
    $x / 10 ** $p

  precision: ($x) ->
    Math.abs @integer(@log10(Math.abs($x)) - @SIGNIFICANT)

  _subtprob: ($n, $x) ->
    $a = undefined
    $b = undefined
    $w = Math.atan2($x / Math.sqrt($n), 1)
    $z = Math.cos($w) ** 2
    $y = 1
    $i = $n - 2
    while $i >= 2
      $y = 1 + ($i - 1) / $i * $z * $y
      $i -= 2
    if $n % 2 == 0
      $a = Math.sin($w) / 2
      $b = .5
    else
      $a = if $n == 1 then 0 else Math.sin($w) * Math.cos($w) / Math.PI
      $b = .5 + $w / Math.PI
    @max 0, 1 - $b - ($a * $y)

  log10: ($n) ->
    Math.log($n) / Math.log(10)

  max: () ->
    $max = arguments[0]
    $i = 0
    while $i < arguments.length
      if $max < arguments[$i]
        $max = arguments[$i]
      $i++
    $max

  # ---
  # generated by js2coffee 2.2.0