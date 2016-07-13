'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class GetDataMsgService extends BaseModuleMessageService
  @msgList:
    outgoing: ['save data']
    incoming: ['get data']
    scope: ['getData']
