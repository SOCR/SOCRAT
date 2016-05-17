'use strict'

# create new class by inheriting from base
class Cluster extends socrat.Module

# inject msgService as dependency
Cluster.$inject = ['app_analysis_cluster_msgService']

# create service
angular.module 'app_analysis_cluster', []
  .service 'app_analysis_cluster_constructor', Cluster
