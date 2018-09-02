'use strict'

ModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class MyModuleMsgService extends ModuleMessageService
  msgList:
    outgoing: ['getData', 'infer data types', 'count.distinct']
    incoming: ['takeTable', 'data types inferred', 'count.distinct_res']
    scope: ['my_module']
