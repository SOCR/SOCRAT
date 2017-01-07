'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcMainCtrl extends BaseCtrl
  @inject '$timeout', '$scope'

  initialize: ->
    console.log("mainArea initialized")
    @cfap = require 'powercalc'
    @title = 'Power Calculator Module'
    #algorithm type
    @selectedAlgorithm = "Select"

    #variables needed for cfap only
    @me=0.09297
    @n=101
    @maxn=120
    @maxme=0.12
    @conf_level=0.95
    @cfap_click()
    @cfap_submit()

    @$scope.$on 'powercalc:updateAlgorithm', (event, data)=>
      @selectedAlgorithm = data
      console.log("broadcasting received")
      console.log("algorithms updated, cfap:", @is_cfap)


  #cfap function only
  cfap_clk: (evt) ->
    obj = evt.currentTarget
    #console.log(evt.currentTarget.value)
    if obj
      id=obj.id;
      ck=$(obj).prop("checked")
      if ck
        console.log(evt.currentTarget.value)
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
    @cfap_submit id, key, evt.target.value

  cfap_click: () ->
    $('#nui').slider(
      animate: 'slow'
      value: @n
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
      value: @me
      min: 0
      max: @maxme
      range: "min"
      step: 0.00001
      slide: (event, ui) =>
        $('#me').val ui.value
        @cfap_submit '1', 'ME', ui.value
        return
    )
    $('#me').val $('#meui').slider('value')
    $("#slider").slider(
      min: 0.90
      max: 0.99
      value: @conf_level
      orientation: "horizontal"
      range: "min"
      step: 0.01
      slide: (event, ui) =>
        @conf_level = ui.value
        $('#conf').val ui.value
        @cfap_submit '1', 'conf', ui.value
        return
    )
    return


  #cfap function only
  cfap_submit: (id, key, value) ->
    d = @cfap.cfap(id, key, value);
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
    @me = d.ME
    if @me > @maxme
      @maxme = (@me / 0.02 + 1) * 0.02
    @n = d.n
    if @n > @maxn
      @maxn = (@n / 20 + 1) * 20
    @cfap_click()
    return

  cfap_changeSlider: (sliderId, evt) ->
    console.log("changeSlider hit")
    key = evt.target.value
    console.log(key)
    @cfap_submit '1', sliderId, key
    return
