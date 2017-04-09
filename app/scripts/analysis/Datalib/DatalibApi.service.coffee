'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class DatalibApi extends BaseModuleInitService
  @inject '$q',
<<<<<<< HEAD
    '$timeout',
    'app_analysis_datalib_dataAdaptor',
    'app_analysis_datalib_msgService'
    'app_analysis_datalib_wrapper'

  initialize: ->
    @eventManager = @app_analysis_datalib_msgService
    @dataAdaptor = @app_analysis_datalib_dataAdaptor
    @dl = @app_analysis_datalib_wrapper

=======
    '$timeout'
    'app_analysis_datalib_dataAdaptor'
    'app_analysis_datalib_msgService'

  initialize: ->
    @msgService = @app_analysis_datalib_msgService
    @dataAdaptor = @app_analysis_datalib_dataAdaptor

    @dl = require 'datalib'
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
    @DATA_TYPES = null

  initDl: () ->
    @$timeout =>
<<<<<<< HEAD
      @DATA_TYPES = @eventManager.getSupportedDataTypes()
      console.log @dl
      if @setDlListeners()
        console.log 'Datalib: ready'
      else
        console.log 'Datalib: failed to start'

  inferType: (obj) =>
    if obj.dataFrame? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
      colData = @dataAdaptor.toColTable obj.dataFrame
      types = @dl.typeInfer colData.map (col) -> col.values
      colData = colData.map (col, i) -> col.type = types.i
      data = @dataAdaptor.toDataFrame colData
    else false

  inferAll: (obj) =>
    if obj.dataFrame? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
      dataFrame = obj.dataFrame
      types = @dl.typeInferAll dataFrame.data
      dataFrame.types = dataFrame.types.map (type, i) -> type = types[i]
      dataFrame
    else false

  setDlListeners: () ->

    msgList = @eventManager.getMsgList()
    methods = [
      incoming: msgList.incoming[0]
      outgoing: msgList.outgoing[0]
      event: @inferType
    ,
      incoming: msgList.incoming[1]
      outgoing: msgList.outgoing[1]
      event: @inferAll
    ]

    status: methods.map (method) =>
      @eventManager.subscribe method['incoming'],
        (msg, obj) =>
          # invoke callback
          data = method.event.apply null, [obj]

          @eventManager.publish method['outgoing'],
            ->
            data
=======
      @DATA_TYPES = @msgService.getSupportedDataTypes()
      console.log @dl
      # extract names of all available functions from the object
      dlApi = []
      @iterateOverObj @dl, dlApi
      console.log dlApi
      # subscribe using indentified methods as messages
      @subscribeForApiMethods dlApi

  iterateOverObj: (obj, methods, stack=[]) ->
    for own key, prop of obj
      if Object.prototype.toString.call(prop) is '[object Function]'
        fullKey = stack + '.' + key
        methods.push fullKey[1..]
      if prop is Object(prop)
        @iterateOverObj prop, methods, fullKey

  subscribeForApiMethods: (api) ->
    # get existing functions from object by names
    methods = ({msg: m, func: @fetchPropFromObj(@dl, m)} for m in api).filter (o) -> o.func?
    # create callbacks for each method
    methods.map (o) => o['cb'] = @createCallback o.func
    # add method names as messages
    methods.map (o) => @msgService.addMsgPair o.msg
    # ask Core to subscribe to newly added message responses
    @msgService.updateMessageMap methods.map (o) -> o.msg + '_res'
    # subscribe for incoming
    methods.map (o) =>
      @msgService.subscribe o.msg,
        (msg, obj) =>
          # invoke callback
          res = o.cb.apply null, [obj]
          # return results
          @msgService.publish o.msg + '_res',
            -> res,
            data: res

  fetchPropFromObj: (obj, prop) =>
    return false if !obj?

    idx = prop.indexOf '.'
    if idx > -1
      @fetchPropFromObj(obj[prop[..idx-1]], prop[idx+1..])
    else
      obj[prop]

  createCallback: (func) =>
    cb = (obj) =>
      if obj.dataFrame? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        res = func obj.dataFrame.data
      else false
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
