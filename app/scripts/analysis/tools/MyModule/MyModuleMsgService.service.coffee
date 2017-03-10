'use strict'
# import base messaging module class
BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'
# export custom messaging service class
module.exports = class MyModuleMsgService extends BaseModuleMessageService
  # define module message list
  msgList:
    outgoing: ['getData', 'infer data types']
    incoming: ['takeTable', 'data types inferred']
# currently scope is same as module id
    scope: ['socrat_analysis_mymodule']
