'use strict'

#class Cluster extends socrat.Module

#cluster = -> new Cluster()
cluster = -> new socrat.Module()
cluster.$inject = ['app_analysis_cluster_msgService']

angular.module('app_analysis_cluster', [])
  .factory('app_analysis_cluster_constructor', cluster)
