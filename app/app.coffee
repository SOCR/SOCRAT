'use strict'

# base libraries
$ = require 'jquery'
require 'angular'
require 'bootstrap/dist/css/bootstrap.css'
require 'angular-ui-bootstrap'
require 'imports?this=>window!bootstrap-switch'
require 'bootstrap-tagsinput'
require 'holderjs'
require 'typeahead.js'
require 'select2'
require 'angular-bootstrap-switch'
require 'designmodo-flat-ui/dist/css/flat-ui.min.css'
require 'designmodo-flat-ui/dist/fonts/glyphicons/flat-ui-icons-regular.woff'
require 'designmodo-flat-ui/dist/fonts/lato/lato-black.woff'
require 'designmodo-flat-ui/dist/fonts/lato/lato-bold.woff'
require 'designmodo-flat-ui/dist/fonts/lato/lato-bolditalic.woff'
require 'designmodo-flat-ui/dist/fonts/lato/lato-italic.woff'
require 'designmodo-flat-ui/dist/fonts/lato/lato-light.woff'
require 'designmodo-flat-ui/dist/fonts/lato/lato-regular.woff'
require 'flatui-radiocheck'
require 'angular-ui-router'
require 'angular-sanitize'
require 'angular-cookies'
require 'angular-resource'
require 'styles/app.less'

# TODO: consider relocating to Charts
require("expose?vg!vega")
require("expose?vl!vega-lite")
require 'vega-embed/vega-embed.js'
require 'compassql'

# create app-level modules
angular.module 'app_services', []
angular.module 'app_controllers', []
angular.module 'app_directives', []

# base app components
require 'scripts/App/AppCtrl.coffee'
require 'scripts/App/AppSidebarCtrl.coffee'
require 'scripts/App/AppMainCtrl.coffee'
require 'scripts/App/AppMenubarDirective.coffee'
require 'scripts/App/AppNotification.directive.coffee'
require 'scripts/App/filters.coffee'
require 'scripts/App/services.coffee'

bodyTemplate = require 'index.jade'
document.body.innerHTML = bodyTemplate()

# load app configs

ModuleList = require 'scripts/App/AppModuleList.coffee'
AppConfig = require 'scripts/App/AppConfig.coffee'
# create an instance of Core
core = require 'scripts/core/Core.coffee'

###
  NOTE: Order of the modules injected into "app" module decides
  which module gets initialized first.
  Their config blocks are executed in the injection order.
  After that config block of "app" is executed.
  Then the run blocks are executed in the same order.
  Run block of "app" is executed in the last.
###

moduleList = new ModuleList()
appConfig = new AppConfig moduleList

# Create app module and pass all modules as dependencies
angular.module 'app', moduleList.listAll()
# Config block
.config appConfig.getConfigBlock()
# Run block
.run appConfig.getRunBlock()
