'use strict'

module.extend = class MenubarDirective

  constructor: () ->
#    @controller = () ->
#    @controllerAs = 'menu'
  restrict: 'E'
  template: require('partials/analysis-nav.jade')()
#  link:(scope,elem,attr)->

angular.module 'app_directives', []
.directive 'menubar', -> new MenubarDirective()
