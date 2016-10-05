'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.extend = class AppMenubarDirective extends BaseDirective

  initialize: () ->
    @restrict = 'E'
    @template = require('partials/analysis-nav.jade')()
#    @link = (scope, elem, attr) =>

dirsMod = angular.module 'app_directives'
AppMenubarDirective.register dirsMod, 'menubar'
