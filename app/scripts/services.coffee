'use strict'

### Sevices ###

services = angular.module('app.services', [])

services.factory 'version', -> "0.0.1.0"

#services.config([
#  ()->
#    console.log "config block of app.services module"
#])
#
#services.run([ ()->
#  console.log "run block of app.services "
#])