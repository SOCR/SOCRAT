'use strict'

### Directives ###

# register the module with Angular
angular.module('app_directives', [
  # require the 'app.service' module
  'app_services'
])

.directive('appVersion', [
  'version'

(version) ->

  (scope, elm, attrs) ->
    elm.text(version)
])
