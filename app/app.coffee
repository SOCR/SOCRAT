'use strict'

# base libraries
require 'angular'
require 'bootstrap/dist/css/bootstrap.css'
require 'angular-ui-bootstrap'
require 'angular-ui-router'
require 'angular-sanitize'
require 'angular-cookies'
require 'angular-resource'
require 'styles/app.less'

# base app components
require 'scripts/controllers.coffee'
require 'scripts/directives.coffee'
require 'scripts/filters.coffee'
require 'scripts/services.coffee'

# core
require 'scripts/core/Core.coffee'

#require 'scripts/analysis/tools/Cluster/-Cluster.module.coffee'

bodyTemplate = require 'index.jade'
document.body.innerHTML = bodyTemplate()

###
  NOTE: Order of the modules injected into "app" module decides
  which module gets initialized first.
  In this case, ngCookies config block is executed first, followed by
  ngResource and so on. Finally config block of "app" is executed.
  Then the run block is executed in the same order.
  Run block of "app" is executed in the last.
###

angular.module('app', [
  'ui.router'
  'ui.router.compat'
  'ngCookies'
  'ngResource'
  'ngSanitize'
  'app_controllers'
  'app_directives'
  'app_filters'
  'app_services'
  'app_core'
  'app_mediator'
#  'app_database'
#  #charts module
##  'app_analysis_charts'
#  # Analysis modules
#  'app_analysis_getData'
##  'app_analysis_wrangleData'
##  'app_analysis_instrPerfEval'
#  'app_analysis_cluster'
])

# Config block
.config(require 'scripts/app.config.coffee')
# Run block
.run(require 'scripts/app.run.coffee')
