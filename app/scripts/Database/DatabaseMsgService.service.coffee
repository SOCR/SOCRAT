'use strict'

ModuleMessageService = require 'scripts/BaseClasses/ModuleMessageService.coffee'

module.exports = class DatabaseMsgService extends ModuleMessageService
  @msgList =
    incoming: ['save table','create table', 'get table', 'delete table']
    outgoing: ['table saved','table created', 'take table', 'table deleted']
    scope: ['database']
