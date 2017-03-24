'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcMainCtrl extends BaseCtrl
  @inject 'app_analysis_powercalc_msgService','$timeout', '$scope'

  initialize: ->
    console.log("mainArea initialized")
    @powerAnalysis = require 'powercalc'
    @msgService = @app_analysis_powercalc_msgService
    @title = 'Power Calculator Module'
    #algorithm type
    @selectedAlgorithm = "Select"

    @dataType = ''
    @dataPoints = null
    @means = null
    @assignments = null
    @populations = {}
    @deployed = false

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
    @TwoTGUI_nn = 2;
    @TwoTGUI_sigma1=0.1;
    @TwoTGUI_sigma2=0.1;
    @TwoTGUI_n1=10;
    @TwoTGUI_n2=10;
    @TwoTGUI_diff=0.5;
    @TwoTGUI_power=0;
    @TwoTGUI_maxsigma1=1.4;
    @TwoTGUI_maxsigma2=1.4;
    @TwoTGUI_maxn1=35;
    @TwoTGUI_maxn2=35;
    @TwoTGUI_maxdiff=1.0;
    @TwoTGUI_maxpower=1;
    @TwoTGUI_maxdf = 100;
    @TwoTGUI_help=false;
    @TwoTGUI_alloc_value=0;
    @TwoTGUI_opt_value=0;
    @TwoTGUI_alpha=0.001;
    @TwoTGUI_threshold=1;
    @TwoTGUI_df=1;
    @TwoTGUI_update();
    
    @$scope.$on 'powercalc:updateAlgorithm', (event, data)=>
      @selectedAlgorithm = data
      console.log("algorithms updated:", @selectedAlgorithm)

    @$scope.$on 'powercalc:drive_data', (event, data)=>
      @populations = data.populations
      @chosenCols = data.chosen
      @drive_data()
      #console.log(@chosenCols)
      #console.log("pops updated:", @populations)

    @$scope.$on 'powercalc:change_mode', (event, data)=>
      @deployed=data.deploy
      @TwoTGUI_click()


  drive_data: () ->
    if (@selectedAlgorithm is "Two-sample t test (general case)")
      if (@chosenCols.length isnt 2)
        window.alert("Must choose two samples")
      else
        @TwoTGUI_receive_data()
    if (@selectedAlgorithm is "CI for One Proportion")
      if (@chosenCols.length isnt 1)
        window.alert("Must choose one sample")
      else
        @cfap_submit("1", "n", @populations[@chosenCols[0]])



    

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

  #functions for TwoTGUI only
  TwoTGUI_receive_data: () ->
    @TwoTGUI_sigma1 = @populations[@chosenCols[0]]["sigma"]
    @TwoTGUI_sigma2 = @populations[@chosenCols[1]]["sigma"]
    @TwoTGUI_n1 = @populations[@chosenCols[0]]["counter"]
    @TwoTGUI_n2 = @populations[@chosenCols[1]]["counter"]
    @TwoTGUI_diff = 0.01 * (@TwoTGUI_sigma1 + @TwoTGUI_sigma2)
    @TwoTGUI_click()
  TwoTGUI_click: () ->
    @TwoTGUI_maxsigma1 = Math.max(@TwoTGUI_sigma1, @TwoTGUI_maxsigma1)
    @TwoTGUI_maxsigma2 = Math.max(@TwoTGUI_sigma1, @TwoTGUI_maxsigma2)
    @TwoTGUI_maxn1 = Math.max(@TwoTGUI_n1, @TwoTGUI_maxn1)
    @TwoTGUI_maxn2 = Math.max(@TwoTGUI_n2, @TwoTGUI_maxn2)
    @TwoTGUI_maxdf = Math.max(@TwoTGUI_df, @TwoTGUI_maxdf)
    @TwoTGUI_maxdiff = Math.max(@TwoTGUI_diff, @TwoTGUI_maxdiff)
    @TwoTGUI_maxpower = Math.max(@TwoTGUI_power, @TwoTGUI_maxpower)
    $( "#sigma1uii" ).slider(
      value: @TwoTGUI_sigma1,
      min: 0,
      max: @TwoTGUI_maxsigma1,
      range: 'min', 
      step: 0.01,
      if !@deployed
        slide: ( event, ui ) =>
          $( "#sigma1i" ).val( ui.value );
          @TwoTGUI_sigma1 = ui.value
          @TwoTGUI_update()
          return
    )
    $( "#sigma1i" ).val( $( "#sigma1uii" ).slider( "value" ) );
    $( "#sigma2uii" ).slider(
      value:@TwoTGUI_sigma2,
      min: 0,
      max: @TwoTGUI_maxsigma2,
      range: "min", 
      step: 0.01,
      if !@deployed
        slide: ( event, ui ) =>
          $( "#sigma2i" ).val( ui.value );
          @TwoTGUI_sigma2 = ui.value
          @TwoTGUI_update()
          return
    )          
    $( "#sigma2i" ).val( $( "#sigma2uii" ).slider( "value" ) );
    $( "#n1uii" ).slider(
      value:@TwoTGUI_n1,
      min: 0,
      max: @TwoTGUI_maxn1,
      range: "min", 
      step: 0.0025,
      if !@deployed
        slide: ( event, ui ) =>
          $( "#n1i" ).val( ui.value );
          @TwoTGUI_n1 = ui.value
          @TwoTGUI_update()
          return
    )          
    $( "#n1i" ).val( $( "#n1uii" ).slider( "value" ) );
    $( "#n2uii" ).slider(
      value:@TwoTGUI_n2,
      min: 0,
      max: @TwoTGUI_maxn2,
      range: "min", 
      step: 0.0025,
      if !@deployed
        slide: ( event, ui ) =>
          $( "#n2i" ).val( ui.value );
          @TwoTGUI_n2 = ui.value
          @TwoTGUI_update()
          return
      )        
    $( "#n2i" ).val( $( "#n2uii" ).slider( "value" ) );
    $( "#diffuii" ).slider(
      value:@TwoTGUI_diff,
      min: 0,
      max: @TwoTGUI_maxdiff,
      range: "min", 
      step: 0.005,
      if !@deployed
        slide: ( event, ui ) =>
          $( "#diffi" ).val( ui.value );
          @TwoTGUI_diff = ui.value
          @TwoTGUI_update()
          return
    )         
    $( "#diffi" ).val( $( "#diffuii" ).slider( "value" ) );
    $( "#poweruii" ).slider(
      value:@TwoTGUI_power,
      min: 0.0001,
      max: 0.9999,
      range: "min", 
      step: 0.0001,
      if !@deployed
        slide:  ( event, ui ) =>
          $( "#poweri" ).val( ui.value );
          @TwoTGUI_power = ui.value
          @TwoTGUI_update("power")
          return
    )         
    $("#poweri").val($("#poweruii").slider("value"));
    $("#alphauii").slider(
      min: 0.001
      max: 0.200
      value: @TwoTGUI_alpha
      orientation: "horizontal"
      range: "min"
      step: 0.001
      slide: (event, ui) =>
        @TwoTGUI_alpha = ui.value
        $('#alphai').val ui.value
        @TwoTGUI_update()
        return
    )
    $("#alphai").val($("#alphauii").slider("value"));
    $("#threshuii").slider(
      min: 0
      max: 100
      value: @TwoTGUI_threshold
      orientation: "horizontal"
      range: "min"
      step: 1
      slide: (event, ui) =>
        @TwoTGUI_alpha = ui.value
        $('#threshi').val ui.value
        #@TwoTGUI_submit '1', 'thresh', ui.value
        return
    )
    $("#dfuii").slider(
      min: 0
      max: @TGUI_maxdf
      value: @TwoTGUI_df
      orientation: "horizontal"
      range: "min"
      step: 1
      disabled: "false"
      if !@deployed
        slide: (event, ui) =>
          @TwoTGUI_df = ui.value
          $('#dfi').val ui.value
          @TwoTGUI_update()
          return
    )
    $("#dfi").val($("#dfuii").slider("value"));
    if @deployed is true
      $("#sigma1uii").slider("disable")
      $("#sigma2uii").slider("disable")
      $("#n1uii").slider("disable")
      $("#n2uii").slider("disable")
      $("#diffuii").slider("disable")
      $("#poweruii").slider("disable")
      return
    else 
      $("#sigma1uii").slider("enable")
      $("#sigma2uii").slider("enable")
      $("#n1uii").slider("enable")
      $("#n2uii").slider("enable")
      $("#diffuii").slider("enable")
      $("#poweruii").slider("enable")
      return
  TwoTGUI_clk: (evt) ->
    obj=evt.currentTarget
    if obj
      id=obj.name;          
      cks=$(obj).prop("checked");
      #console.log('hit');
      #console.log(id);
      if cks
        @TwoTGUI_submit("1",id,"1");
      else
        @TwoTGUI_submit("1",id,"");
      return
  TwoTGUI_update: (power) ->
    if power isnt "power"
      d = @powerAnalysis.TwoTGUI_dataDrivenMode_getpower(@TwoTGUI_sigma1, @TwoTGUI_sigma2, @TwoTGUI_n1, @TwoTGUI_n2, @TwoTGUI_alpha, @TwoTGUI_df, @TwoTGUI_diff)
    else
      d = @powerAnalysis.TwoTGUI_dataDrivenMode_changepower(@TwoTGUI_sigma1, @TwoTGUI_sigma2, @TwoTGUI_n1, @TwoTGUI_n2, @TwoTGUI_alpha, @TwoTGUI_df, @TwoTGUI_diff, @TwoTGUI_power)
    @TwoTGUI_sigma1=d.sigma1;
    @TwoTGUI_sigma2=d.sigma2;
    #$("sigma1i").prop("value", d.sigma1)
    #$("sigma2i").prop("value", d.sigma2)

    # if d.eqs is 1
    #   $("#eqsi").prop("checked","checked");
    #   $("#sigma2i").prop("value",d.sigma1);
    #   @TwoTGUI_sigma2=d.sigma1;
    # else
    #   $("#eqsi").prop("checked","");
    #   $("#sigma2i").prop("value",d.sigma2);
    #   @TwoTGUI_sigma2=d.sigma2;

    #$("#n1i").prop("value",d.n1);
    #$("#n2i").prop("value",d.n2);
    @TwoTGUI_n1=d.n1;
    @TwoTGUI_n2=d.n2;
    @TwoTGUI_df=d.df;

    # $("#alloci").prop("value",d.alloc);
    # if d.tt is 1
    #   $("#tti").prop("checked","checked");

    #$("#alphai").prop("value",d.alpha);

    # if d.equiv is 1
    #   $("#equivi").prop("checked","checked");
    #   $("#threshi").val(d.thresh);
    #   $("#threshShowi").show();
    # else
    #   $("#equivi").prop("checked","");
    #   $("#threshShowi").hide();
    #$("#dfi").prop("value",d.df);

    #$("#diffi").prop("value",d.diff);
    #$("#poweri").prop("value",d.power);
    @TwoTGUI_diff=d.diff;
    @TwoTGUI_power=d.power;

    #$("#opti").prop("value",d.opt);

    @TwoTGUI_click();
  TwoTGUI_valiad1: (evt) ->
    id = evt.target.name
    data = evt.target.value
    event = evt
    e = event || window.event || arguments.callee.caller.arguments[0]
    r=/^\d+(\.\d+)?$/;
    rr=/^0\.[0-9]\d*$/;
    if rr.test(data)
      @TwoTGUI_submit('1',id,data);
    else
      return false;
  TwoTGUI_valiad: (evt) ->
    id = evt.target.name
    data = evt.target.value
    event = evt
    e = event || window.event || arguments.callee.caller.arguments[0];
    r=/^\d+(\.\d+)?$/;
    rr=/^0\.[0-9]\d*$/;
    if r.test(data)
      @TwoTGUI_submit('1',id,data);
    else
      return false
  TwoTGUI_changeSlider: (sliderId, evt) ->
    if !@deployed
      key = evt.target.value
      @TwoTGUI_update()
    return
  TwoTGUI_alloc_submit: (id,key) ->
    #@TwoTGUI_submit(id, key, @TwoTGUI_alloc_value)
    return
  TwoTGUI_opt_submit: (id,key) ->
    #@TwoTGUI_submit(id, key, @TwoTGUI_opt_value)
    return
  TwoTGUI_show_help: () ->
    if @TwoTGUI_help is true
      $('#TwoTGUI_H').val "Show Help"
    else
      $('#TwoTGUI_H').val "Hide Help"
    @TwoTGUI_help = !@TwoTGUI_help
    return
