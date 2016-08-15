'use strict'

ModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class ChartsMsgService extends ModuleMessageService
  msgList:
    outgoing: ['get table']
    incoming: ['take table']
    scope: ['app_analysis_charts']
