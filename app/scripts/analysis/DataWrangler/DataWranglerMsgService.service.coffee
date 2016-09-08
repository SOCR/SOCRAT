'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class DataWranglerMsgService extends BaseModuleMessageService
  msgList:
    outgoing: ['getData', 'saveData']
    incoming: ['takeTable']
    scope: ['app_analysis_dataWrangler']
