'use strict'

ModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class ChartsMsgService extends ModuleMessageService
  msgList:
    outgoing: ['getData']
    incoming: ['takeTable']
    scope: ['app_analysis_charts']
