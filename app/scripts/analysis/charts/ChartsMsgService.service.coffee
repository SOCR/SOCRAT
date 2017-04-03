'use strict'

ModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'

module.exports = class ChartsMsgService extends ModuleMessageService
  msgList:
    outgoing: ['getData', 'infer data types']
    incoming: ['takeTable', 'data types inferred']
    scope: ['app_analysis_charts']
