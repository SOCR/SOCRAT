'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class DataWranglerMsgService extends BaseModuleMessageService
  msgList:
    outgoing: ['get data', 'save data']
    incoming: ['wrangle data']
    scope: ['app_analysis_dataWrangler']
