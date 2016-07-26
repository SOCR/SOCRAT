'use strict'

BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class DataWranglerMsgService extends BaseModuleMessageService
  msgList:
    outgoing: ['save data']
    incoming: ['get data']
    scope: ['app_analysis_dataWrangler']
