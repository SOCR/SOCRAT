'use strict'

MessageService = require 'scripts/Module/MessageService.coffee'

module.exports = class ClusterMsgService extends MessageService
  @msgList:
    outgoing: ['get table']
    incoming: ['take table']
    scope: ['cluster']

ClusterMsgService.$inject = ['$q', '$rootScope', '$stateParams']
