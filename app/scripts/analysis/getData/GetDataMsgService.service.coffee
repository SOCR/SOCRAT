'use strict'

ModuleMessageService = require 'scripts/BaseClasses/ModuleMessageService.coffee'

module.exports = class GetDataMsgService extends ModuleMessageService
  @msgList:
    outgoing: ['save data']
    incoming: ['get data']
    scope: ['getData']
