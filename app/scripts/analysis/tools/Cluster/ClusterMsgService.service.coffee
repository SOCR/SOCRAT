'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class ClusterMsgService extends BaseModuleMessageService
  msgList:
    outgoing: ['getData']
    incoming: ['takeTable']
    # currently scope is same as module id
    scope: ['app_analysis_cluster']
