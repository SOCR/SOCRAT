'use strict'

#module.extend = class AppMenubarDirective
#
#  constructor: () ->
#  restrict: 'E'
#  template: require('partials/analysis-nav.jade')()
#
#angular.module 'app_directives', []
#.directive 'menubar', -> new AppMenubarDirective()

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.extend = class AppMenubarDirective extends BaseDirective
  @inject 'app_directives_service'

  initialize: () ->
    restrict: 'E'
    template: require('partials/analysis-nav.jade')()

dirsMod = angular.module 'app_directives', []
dirsMod.service('app_directives_service',[
  '$timeout'
  ($timeout) ->
    timeout: -> $timeout
  ])
AppMenubarDirective.register dirsMod, 'menubar'
