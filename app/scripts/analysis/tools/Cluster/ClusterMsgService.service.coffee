'use strict'

ModuleMessageService = require 'scripts/BaseClasses/ModuleMessageService.coffee'

module.exports = class ClusterMsgService extends ModuleMessageService
  @msgList:
    outgoing: ['get table']
    incoming: ['take table']
    scope: ['cluster']
