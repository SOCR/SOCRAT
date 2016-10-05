'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name BaseModuleMessageService
  @desc Base class for module messaging service
###

module.exports = class BaseModuleMessageService extends BaseService
  @inject '$q', '$rootScope', '$stateParams'

  initialize: () ->
    @sb = null

  setSb: (sb) ->
    @sb = sb

  getMsgList: () ->
    @msgList

  getSupportedDataTypes: () ->
    if @sb
      @sb.getSupportedDataTypes()
    else
      false

  # wrapper function for controller communications
  broadcast: (msg, data) ->
    @$rootScope.$broadcast msg, data

  publish: (msg, cb, dataFrame=null, deferred=null) ->
    if @sb and msg in @msgList.outgoing
      deferred = @$q.defer() unless deferred?
      @sb.publish
        msg: msg
        msgScope: @msgList.scope
        callback: -> cb
        data:
          tableName: @$stateParams.projectId + ':' + @$stateParams.forkId
          promise: deferred
          dataFrame: dataFrame
    else false

  subscribe: (msg, listener) ->
    if @sb and msg in @msgList.incoming
      token = @sb.subscribe
        msg: msg
        msgScope: @msgList.scope
        listener: listener
      token
    else false

  unsubscribe: (token) ->
  if @sb
    @sb.unsubscribe token
  else false
