'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class DatalibMsgService extends BaseModuleMessageService
  msgList:
    incoming: ['infer type', 'infer all types']
    outgoing: ['type inferred', 'all types inferred']
    scope: ['app_analysis_datalib']
