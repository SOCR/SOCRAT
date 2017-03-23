'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class DatalibApi extends BaseModuleInitService
  @inject '$q',
    '$timeout'
    'app_analysis_datalib_dataAdaptor'
    'app_analysis_datalib_msgService'
    'app_analysis_datalib_wrapper'
    'app_analysis_datalib_apiBuilder'

  initialize: ->
    @eventManager = @app_analysis_datalib_msgService
    @dataAdaptor = @app_analysis_datalib_dataAdaptor
    @dl = @app_analysis_datalib_wrapper
    @apiBuilder = @app_analysis_datalib_apiBuilder

    @DATA_TYPES = null

  initDl: () ->
    @$timeout =>
      @DATA_TYPES = @eventManager.getSupportedDataTypes()
      console.log @dl

      #TODO: dynamically create methods array
#      @dlApi = @apiBuilder.createApi @dl.dl
#      console.log @dlApi
#      @subscribeForApiMethods @dlApi
      if @setDlListeners()
        console.log 'Datalib: ready'
      else
        console.log 'Datalib: failed to start'

  subscribeForApiMethods: (api) ->
    for method in api
      func = @fetchPropFromObj(@dl, method)
      @msgService.addIncomingMsg method
      @msgService.subscribe method, func unless !func?

  fetchPropFromObj: (obj, prop) =>
    return false if !obj?

    idx = prop.indexOf '.'
    if idx > -1
      @fetchPropFromObj(obj[prop[..idx-1]], prop[idx+1..])
    else
      obj[prop]

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
