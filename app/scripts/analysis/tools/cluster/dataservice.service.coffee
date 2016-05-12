'use strict'

( ->
  dataService = (msgManager, $q) ->

    ############

    getData: ->
      deferred = $q.defer()
      token = msgManager.subscribe 'take data', (msg, data) -> deferred.resolve data
      msgManager.publish 'get data', -> msgManager.unsubscribe token
      deferred.promise

    getDataTypes: ->
      msgManager.getSupportedDataTypes()

  dataService.$inject = ['app_analysis_clustering_msgService', '$q']
  angular
    .module('app_analysis_clustering')
    .factory('app_analysis_clustering_dataService', dataService)
)()
