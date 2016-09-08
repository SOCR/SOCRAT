'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class GetDataMsgService extends BaseModuleMessageService
  msgList:
    outgoing: ['getData', 'saveData']
    incoming: ['takeTable', 'getData']
    scope: ['app_analysis_getData']
