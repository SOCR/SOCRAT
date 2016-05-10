'use strict'

( ->
  constructor = (msgService) ->
    (sb) ->

      msgList = {}
      msgService.setSb sb unless !sb?
      msgList = msgService.getMsgList()

      ############

      init: (opt) ->
        console.log 'clustering init invoked'

      destroy: () ->

      msgList: msgList

  constructor.$inject = ['app_analysis_clustering_msgService']
  clustering = angular.module('app_analysis_clustering', [])
  clustering.factory('app_analysis_clustering_constructor', constructor)
)()
