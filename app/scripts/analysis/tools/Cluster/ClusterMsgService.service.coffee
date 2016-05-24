'use strict'

require 'scripts/_module/MessageService.coffee'

class ClusterMsgService extends socrat.MessageService
  msgList:
    outgoing: ['get table']
    incoming: ['take table']
    scope: ['cluster']

ClusterMsgService.$inject = ['$q', '$rootScope', '$stateParams']

angular
  .module 'app_analysis_cluster'
  .service 'app_analysis_cluster_msgService', ClusterMsgService
