'use strict'

#app.core module contains services like error management , pub/sub

core = angular.module('app.core', [
  'app.services'
])

  .service "core", ->
    _modules = {}
