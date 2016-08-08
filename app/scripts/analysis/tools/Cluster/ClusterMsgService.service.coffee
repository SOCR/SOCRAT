'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class ClusterMsgService extends BaseModuleMessageService
  msgList:
    outgoing: ['get table']
    incoming: ['take table']
    # currently scope is same as module id
    scope: ['app_analysis_cluster']
