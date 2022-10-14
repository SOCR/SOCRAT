'use strict'
# import base messaging module class
BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'
# export custom messaging service class
module.exports = class ProjectorMsgService extends BaseModuleMessageService
  # required to define module message list
  msgList:
    outgoing: ['getData']
    incoming: ['takeTable']
    scope: ['app_analysis_projector']