'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

appControllers = angular.module 'app_controllers'

module.exports = class AppMainCtrl extends BaseCtrl
  @register appControllers
  @inject '$scope', 'appSidebarState'

  initialize: ->
    #initial width is set .col-md-9
    @width = 'col-md-9'

    #updating main view
    @$scope.$on 'update view', =>
      if @appSidebarState.sidebar is 'visible' and @appSidebarState.history is 'hidden'
        @width = 'col-md-9'
      else
        @width = 'col-md-11'
