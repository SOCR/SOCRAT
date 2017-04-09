'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class DatalibMsgService extends BaseModuleMessageService
  msgList:
<<<<<<< HEAD
    incoming: ['infer type', 'infer all types']
    outgoing: ['type inferred', 'all types inferred']
    scope: ['app_analysis_datalib']
=======
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
    console.log msgs
    @publish @msgList.outgoing[0],
      -> console.log('updated Core message map'),
      scope: @msgList.scope
      msgList: msgs
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
