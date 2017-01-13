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

    #variables needed for cfap only
    @cfap_me=0.09297
    @cfap_n=101
    @cfap_maxn=120
    @cfap_maxme=0.12
    @cfap_conf_level=0.95
    @cfap_help=false
    @cfap_click()
    @cfap_submit()
    #@cfap_show_help()

    #variables needed for cimean only
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
    #@cimean_show_help()

    @$scope.$on 'powercalc:updateAlgorithm', (event, data)=>
      @selectedAlgorithm = data
      #console.log("algorithms updated:", @selectedAlgorithm)

  #global
  update_algo: (evt) ->
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
    d = @powerAnalysis.cfap(id, key, value);
    if d.isFinite == 1
      $('#isFinite').prop 'checked', 'checked'
      $('#showN').show()
    else
      $('#isFinite').prop 'checked', ''
      $('#showN').hide()
    #N
    $('#N').val d.N
    #worstCase
    if d.worstCase == 1
      $('#worstCase').prop 'checked', 'checked'
    else
      $('#worstCase').prop 'checked', ''
    #pi
    $('#pi').val d.pi
    #Conf
    $('#conf').prop 'value', d.conf
    #ME
    $('#me').val d.ME
    #n
    $('#n').val d.n
    #check
    @cfap_me = d.ME
    if @cfap_me > @cfap_maxme
      @cfap_maxme = (@cfap_me / 0.02 + 1) * 0.02
    @cfap_n = d.n
    if @cfap_n > @cfap_maxn
      @cfap_maxn = (@cfap_n / 20 + 1) * 20
    @cfap_conf_level = d.conf
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
    d = @powerAnalysis.CImean(id, key, value)
    if d.isFinite == 1
      $('#isFinitea').prop("checked","checked")
      $('#showNa').show();
    else
      $('#isFinitea').prop("checked","")
      $('#showNa').hide()
    #N
    $('#NN').val(d.NN);
    #signa
    $('#sgn').val(d.Sigma)
    #Conf
    $('#confa').prop("value",d.conf)
    #ME
    $('#mea').val(d.ME)
    #n
    $('#na').val(d.n)                   
    @cimean_signa=d.Sigma
    #check
    @cimean_me=d.ME
    if @cimean_me > @cimean_maxme
      @cimean_maxme=(@cimean_me/0.02+1)*0.02
    @cimean_n=d.n
    if @cimean_n > @cimean_maxn
      @cimean_maxn=(@cimean_n/20+1)*20
    @cimean_conf_level = d.conf
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