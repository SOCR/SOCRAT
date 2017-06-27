'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class DatalibApi extends BaseModuleInitService
  @inject '$q',
    '$timeout'
    'app_analysis_datalib_dataAdaptor'
    'app_analysis_datalib_msgService'

  initialize: ->
    @msgService = @app_analysis_datalib_msgService
    @dataAdaptor = @app_analysis_datalib_dataAdaptor

    @dl = require 'datalib'
    @DATA_TYPES = null

  initDl: () ->
    @$timeout =>
      @DATA_TYPES = @msgService.getSupportedDataTypes()
      # extract names of all available functions from the object
      dlApi = []
      @iterateOverObj @dl, dlApi
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
