'use strict'

root = exports ? this
console.log 'ROOT cluster ' + root
cluster = new root.Module()

cluster.$inject = ['app_analysis_cluster_msgService']

angular.module('app_analysis_cluster', [])
  .factory('app_analysis_cluster_constructor', cluster)
