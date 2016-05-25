'use strict'

Module = require 'scripts/Module/Module.coffee'

cluster = new Module

  # module id for registration
  id: 'app_analysis_cluster'

  # module components
  components:
    services: [
      initService:
        name: 'app_analysis_cluster_initService'
        func: require 'scripts/analysis/tools/Cluster/ClusterInit.service.coffee'
    ,
      messageService:
        name: 'app_analysis_cluster_messageService'
        func: require 'scripts/analysis/tools/Cluster/ClusterMsgService.service.coffee'
      ]
    factories: []
    controllers: []
    directives: []

  # module state config
  state:
    id: 'cluster'
    url: '/tools/cluster'
    mainTemplate: 'partials/analysis/tools/cluster/main.jade'
    sidebarTemplate: 'partials/analysis/tools/cluster/sidebar.jade'
