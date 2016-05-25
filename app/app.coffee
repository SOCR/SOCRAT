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

bodyTemplate = require 'index.jade'
document.body.innerHTML = bodyTemplate()

###
  NOTE: Order of the modules injected into "app" module decides
  which module gets initialized first.
  Their config blocks are executed in the injection order.
  After that config block of "app" is executed.
  Then the run blocks are executed in the same order.
  Run block of "app" is executed in the last.
###

ModuleList = require 'scripts/app.modules.coffee'

angular.module('app', new ModuleList().modules)
# Config block
.config(require 'scripts/app.config.coffee')
# Run block
.run(require 'scripts/app.run.coffee')
