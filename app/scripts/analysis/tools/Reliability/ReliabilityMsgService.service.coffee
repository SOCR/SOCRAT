'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class ReliabilityMsgService extends BaseModuleMessageService
  msgList:
    outgoing: ['getData', 'infer data types']
    incoming: ['takeTable', 'data types inferred']
    # currently scope is same as module id
    scope: ['app_analysis_reliability']
