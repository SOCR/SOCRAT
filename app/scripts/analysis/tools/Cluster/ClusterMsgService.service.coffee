'use strict'

MessageService = require 'scripts/Module/MessageService.coffee'

class ClusterMsgService extends MessageService
  @msgList:
    outgoing: ['get table']
    incoming: ['take table']
    scope: ['cluster']

ClusterMsgService.$inject = ['$q', '$rootScope', '$stateParams']
