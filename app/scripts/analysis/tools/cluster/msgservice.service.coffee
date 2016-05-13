'use strict'

#class MsgService extends socrat.MessageService

msgService = ->
  new socrat.MessageService
    outgoing: ['get table']
    incoming: ['take table']
    scope: ['cluster']

msgService.$inject = ['$q', '$rootScope', '$stateParams']

angular
  .module('app_analysis_cluster')
  .factory('app_analysis_cluster_msgService', msgService)
