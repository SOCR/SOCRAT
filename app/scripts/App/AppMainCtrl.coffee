'use strict'

module.extend = class AppMainCtrl

  constructor: (@$scope, @appSidebarState) ->
    #initial width is set .col-md-9
    @width = 'col-md-9'

    #updating main view
    @$scope.$on 'update view', ()->
      if @appSidebarState.sidebar is 'visible' and @appSidebarState.history is 'hidden'
        @width = 'col-md-9'
      else
        @width = 'col-md-11'

AppMainCtrl.$inject = ['$scope', 'appSidebarState']

angular.module 'app_controllers'
.controller 'AppMainCtrl', AppMainCtrl
