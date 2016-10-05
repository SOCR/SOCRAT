'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class DatabaseMsgService extends BaseModuleMessageService
  msgList:
    incoming: ['save table', 'create table', 'get table', 'delete table']
    outgoing: ['table saved', 'table created', 'take table', 'table deleted']
    scope: ['app_analysis_database']
