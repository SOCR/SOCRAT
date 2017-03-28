'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class GetDataMsgService extends BaseModuleMessageService
  msgList:
    outgoing: ['getData', 'saveData','data summary','infer data types','data histogram']
    incoming: ['takeTable', 'getData','data summary result','data types inferred','data histogram result']
    scope: ['app_analysis_getData']
