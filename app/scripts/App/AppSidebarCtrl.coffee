'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

appControllers = angular.module 'app_controllers'
appControllers.value 'appSidebarState',
  sidebar:'visible'
  history:'hidden'

module.exports = class AppSidebarCtrl extends BaseCtrl
  @register appControllers
  @inject '$scope', 'appSidebarState'

  initialize: ->
    console.log 'controller block for sidebarCtrl'
    @state = 'show'
    @arrowDirection = 'glyphicon glyphicon-chevron-left'

    # TODO: add dynamic project loading and naming #SOCRFW-24
    @activeProjectName = 'default'

    # toggle sidebar by request
    @$scope.$on 'toggle sidebar', (event, results) =>
      @toggle()

  # view function
  view: ->
    if @state is 'show'
      true
    else
      false

  # toggle function
  toggle: ->
    if @state is 'hidden'
      @state = 'show'
      @appSidebarState.sidebar = 'visible'
      @arrowDirection = 'glyphicon glyphicon-chevron-left'
    else
      @state = 'hidden'
      @appSidebarState.sidebar = 'hidden'
      @arrowDirection = 'glyphicon glyphicon-chevron-right'
    @$scope.$emit 'change in view'

  getClass: ->
    if @state is 'hidden'
      'col-md-1'
    else
      'col-md-3'
