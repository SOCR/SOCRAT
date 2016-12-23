'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcMainCtrl extends BaseCtrl
  @inject '$timeout', '$scope'

  initialize: ->
    console.log("mainArea initialized")

    @cf = require 'powercalc'

    @title = 'Power Calculator Module'
    #algorithm type
    @is_cfap = off

    @$scope.$on 'powercalc:updateAlgorithm', (event, data)=>
      @is_cfap = data
      console.log("broadcasting received")
      console.log("algorithms updated, cfap:", @is_cfap)



  cfap_clk: (evt) ->
    obj = evt.currentTarget
    console.log(obj)
    if obj
      id=obj.id;
      ck=$(obj).prop("checked")
      if ck
        @cfap_submit("1",id,"1")
      else
        @cfap_submit("1",id,"")
    return false



  cfap_valiad: () ->
      @cfap.valiad(id, data, event)

  cfap_submit: (id, key, value) ->
    d = @cf.cfap(id, key, value);
    if d.isFinite is 1
      $('#isFinite').prop("checked","checked")
      $('#showN').show()
    else
      $('#isFinite').prop("checked","")
      $('#showN').hide()
    #N
    $('#N').val(d.N)
    #worstCase
    if d.worstCase is 1
      $('#worstCase').prop("checked","checked")
    else
      $('#worstCase').prop("checked","")
    #pi
    $('#pi').val(d.pi)
    #Conf
    $('#conf').prop("value",d.conf)
    #ME
    $('#me').val(d.ME)
    #n
    $('#n').val(d.n)
    #check
    me=d.ME;
    if me > maxme
      maxme=(me/0.02+1)*0.02;
    n=d.n;
    if n > maxn
      maxn=(n/20+1)*20
    #click()

  cfap_showDiv: (sliderId, key) ->
      @cfap.showDiv(sliderId, key)

  click: () ->
    $('#nui').slider(
      animate: 'slow'
      value: n
      min: 0
      max: 400
      range: false
      step: 0.01
      slide: (event, ui) ->
        $('#n').val ui.value
        submit '1', 'n', ui.value
        return
    ).slider('pips',
      rest: 'label'
      step: 2000).slider 'float'
    $('#n').val $('#nui').slider('value')
    $('#meui').slider(
      value: me
      min: 0
      max: maxme
      range: false
      step: 0.00001
      slide: (event, ui) ->
        $('#me').val ui.value
        submit '1', 'ME', ui.value
        return
    ).slider('pips',
      rest: 'label'
      step: 2000).slider 'float'
    $('#me').val $('#meui').slider('value')
    return

