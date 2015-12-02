'use strict'

### Sevices ###

services = angular.module('app_services', [])

services.factory 'version', -> "v0.1.5-alpha.2"

#services.config([
#  ()->
#    console.log "config block of app.services module"
#])
#
#services.run([ ()->
#  console.log "run block of app.services "
#])
