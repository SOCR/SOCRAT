'use strict'

###
# @name Cluster
# @desc Main class for cluster module inherited from base
###
class Cluster extends socrat.Module

# inject msgService as dependency
Cluster.$inject = ['app_analysis_cluster_msgService']

# create service
angular.module 'app_analysis_cluster', []
  .service 'app_analysis_cluster_starter', Cluster
