'use strict'

ModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class ChartsMsgService extends ModuleMessageService
  msgList:
    outgoing: ['getData', 'infer data types', 'data summary']
    incoming: ['takeTable', 'data types inferred', 'data summary result']
    scope: ['app_analysis_charts']
