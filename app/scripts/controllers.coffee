'use strict'

### Controllers ###
###
  This file contains the controllers that are generic
  and not specific to any particular analysis(clean data or charts etc).
###

app = angular.module('app_controllers', ['app_mediator'])

.config([
    ->
      console.log 'config block of app.controllers module'
])

.controller('AppCtrl', [
  '$scope'
  '$location'
  '$resource'
  '$rootScope'
  'pubSub'
  ($scope, $location, $resource, $rootScope,pubSub) ->
    console.log 'controller block for AppCtrl'
    # Uses the url to determine if the selected
    # menu item should have the class active.

    # Listening to all changes in the view
    $scope.$on 'change in view', ->
      $scope.$broadcast 'update view', null

    $scope.$on 'change in showStates', (obj, data) ->
      console.log 'change in showStates heard!'
      $scope.$broadcast 'update showStates', data

    $scope.$on 'update handsontable', (obj, data) ->
      console.log data
      $scope.$broadcast data.purpose + ':load data to handsontable', data

    # $scope.$on 'get Data from handsontable', ->
      # $scope.$broadcast 'get Data from handsontable'

    $scope.$location = $location
    $scope.username = 'Guest'
    $scope.$watch '$location.path()', (path) ->
      $scope.activeNavId = path || '/'

    # getClass compares the current url with the id.
    # If the current url starts with the id it returns 'active'
    # otherwise it will return '' an empty string. E.g.
    #
    #   # current url = '/products/1'
    #   getClass('/products') # returns 'active'
    #   getClass('/orders') # returns ''
    #

    $scope.getClass = (id) ->
      if $scope.activeNavId.substring(0, id.length) == id
        'active'
      else
        ''

    # callback
    updateUsername = (event, data) ->
      $scope.username = data

    pubSub.subscribe 'username changed', updateUsername

])

.controller('navCtrl', [
    '$scope'
    ($scope) ->
      console.log 'controller block for navCtrl'
])

.controller('subNavCtrl', [
    '$scope'
    ($scope) ->
])

.controller('sidebarCtrl', [
  '$scope'
  'appConfig'
  ($scope, appConfig) ->

    console.log 'controller block for sidebarCtrl'
    $scope.state = 'show'

    # view function
    $scope.view = ->
      if $scope.state is 'show'
        true
      else
        false
    # toggle function
    $scope.toggle = ->
      if $scope.state is 'hidden'
        $scope.state = 'show'
        appConfig.sidebar = 'visible'
      else
        $scope.state = 'hidden'
        appConfig.sidebar = 'hidden'
      $scope.$emit 'change in view'

    $scope.getClass = ->
      if $scope.state is 'hidden'
        'col-md-1'
      else
        'col-md-3'
])

.controller('mainCtrl', [
  '$scope'
  'appConfig'
  '$document'
  ($scope, appConfig, $doc) ->
    console.log $doc
    #initial width is set .col-md-9
    $scope.width = 'col-md-9'
    #updating main view
    $scope.$on 'update view', ()->
      if appConfig.sidebar is 'visible' and appConfig.history is 'hidden'
        $scope.width = 'col-md-9'
      else
        $scope.width = 'col-md-11'
])

.controller('footerCtrl', [
  '$scope'
  ($scope)->
])

.controller('welcomeCtrl', [
  '$scope'
   ($scope)->
])

.controller('projectCtrl', [
  '$scope'
  'pubSub'
  ($scope, pubSub) ->
    console.log 'Project Ctrl'
    $scope.message = 'Enter your name....'
    $scope.messageReceived= ''
    # sendMsg
    $scope.sendMsg = ->
      console.log $scope.message
      pubSub.publish 'username changed', $scope.message
      console.log 'published successfully'
      null

    # unsubMsg
    $scope.unsubMsg = ->
      console.log 'unsubscribe initiated'
      pubSub.unsubscribe $scope.token
      null

    # callback function on event 'message changed'
    updateMsg = (event, msg) ->
      $scope.messageReceived = msg
      console.log 'message received successfully through pub/sub'
      null

    # register function x to event 'message changed'
    $scope.token = pubSub.subscribe 'username changed', updateMsg
])

#
# appConfig - contains all the values for a dynamic UI
#
.value 'appConfig',
  sidebar:'visible'
  history:'hidden'

.run([
  ->
    console.log 'run block of app.controllers '
])

