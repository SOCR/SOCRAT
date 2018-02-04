'use strict'
# import base messaging module class
BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'
# export custom messaging service class
module.exports = class MyModuleMsgService extends BaseModuleMessageService
  # define module message list
  msgList:
    outgoing: ['mymodule:getData']
    incoming: ['mymodule:receiveData']
    # required to be the same as module id
    scope: ['socrat_analysis_mymodule']
