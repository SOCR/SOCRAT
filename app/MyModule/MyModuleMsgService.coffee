'use strict'

ModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class MyModuleMsgService extends ModuleMessageService
  msgList:
    outgoing: ['getData', 'infer data types']
    incoming: ['takeTable', 'data types inferred']
    scope: ['my_module']
