'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class GetDataMsgService extends BaseModuleMessageService
  msgList:
    outgoing: ['getData', 'saveData','data summary']
    incoming: ['takeTable', 'getData','data summary result']
    scope: ['app_analysis_getData']
