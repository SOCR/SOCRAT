'use strict'

class Module
  constructor: (msgService) ->

    init: (@sb) ->

      msgList = {}
      msgService.setSb sb unless !sb?
      msgList = msgService.getMsgList()

      ############

      init: (opt) ->
        console.log 'clustering init invoked'

      destroy: () ->

      msgList: msgList

    start:  () ->

clustering.$inject = ['app_analysis_cluster_msgService']

angular.module('app_analysis_cluster', [])
  .factory('app_analysis_cluster_constructor', clustering)
