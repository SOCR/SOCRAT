'use strict'
# import base messaging module class
BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'
# export custom messaging service class
module.exports = class JiaruiLiuMsgService extends BaseModuleMessageService
  # required to define module message list
  msgList:
    outgoing: ['getData', 'saveData']
    incoming: ['takeTable']
    # required to be the same as module id
    scope: ['socrat_analysis_JiaruiLiu'] 