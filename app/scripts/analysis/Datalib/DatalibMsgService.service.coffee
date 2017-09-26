'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class DatalibMsgService extends BaseModuleMessageService
  msgList:
    incoming: []
    outgoing: ['core_update_subscription']
    scope: ['app_analysis_datalib']

  addInMsg: (msg) ->
    @msgList.incoming.push msg

  addOutMsg: (msg) ->
    @msgList.outgoing.push msg

  addMsgPair: (msg) ->
    @addInMsg msg
    @addOutMsg msg + '_res'

  updateMessageMap: (msgs) ->
    @publish @msgList.outgoing[0],
      -> console.log('updated Core message map'),
      scope: @msgList.scope
      msgList: msgs
