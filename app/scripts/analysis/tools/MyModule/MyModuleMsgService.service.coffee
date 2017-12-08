'use strict'
# import base messaging module class
BaseModuleMessageService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'
# export custom messaging service class
<<<<<<< HEAD
module.exports = class app_analysis_mymodule_msgService extends BaseModuleMessageService
  # required to define module message list
  msgList:
    outgoing: ['getData']
    incoming: ['takeTable']
=======
module.exports = class MyModuleMsgService extends BaseModuleMessageService
  # required to define module message list
  msgList:
    outgoing: ['mymodule:getData']
    incoming: ['mymodule:receiveData']
>>>>>>> master
# required to be the same as module id
    scope: ['app_analysis_mymodule']
