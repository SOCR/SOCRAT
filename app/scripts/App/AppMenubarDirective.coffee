'use strict'

module.extend = class AppMenubarDirective

  constructor: () ->
  restrict: 'E'
  template: require('partials/analysis-nav.jade')()

angular.module 'app_directives', []
.directive 'menubar', -> new AppMenubarDirective()
