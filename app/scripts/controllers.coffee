'use strict'

### Controllers ###

angular.module('app.controllers', ['app.mediator'])

.controller('AppCtrl', [
  '$scope'
  '$location'
  '$resource'
  '$rootScope'
  'pubSub'

($scope, $location, $resource, $rootScope,pubSub) ->

  # Uses the url to determine if the selected
  # menu item should have the class active.
  $scope.$location = $location
  $scope.username="Guest"
  $scope.$watch('$location.path()', (path) ->
    $scope.activeNavId = path || '/'
  )

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
      return 'active'
    else
      return ''


  #callback
  updateUsername=(event,data)->
    $scope.username=data

  pubSub.subscribe("username changed",updateUsername)

])

# SUBMENU CONTROLLER FUNCTIONS
.controller('subMenuCtrl', [
  '$scope'
  'pubSub'

($scope,pubSub) ->
  $scope.message = "Enter your name...."
  $scope.messageReceived=""
  $scope.state="show"

  #sendMsg
  $scope.sendMsg=()->
    console.log(this.token)
    pubSub.publish("username changed",$scope.message)
    console.log("published successfully")
    null

  #unsubMsg
  $scope.unsubMsg=()->
    console.log("unsubscribe initiated")
    pubSub.unsubscribe($scope.token)
    null

  #callback function on event "message changed"
  updateMsg=(event,msg)->
    $scope.messageReceived=msg
    console.log("message received successfully through pub/sub")
    null

  #register function x to event "message changed"
  $scope.token=pubSub.subscribe("username changed",updateMsg)

  #view function
  $scope.view=->
    if $scope.state is "show"
      true
    else
      false
  #toggle function
  $scope.toggle=->
    if $scope.state is "hidden"
      $scope.state="show"
    else
      $scope.state="hidden"

  $scope.getClass=->
    if $scope.state is "hidden"
      "span1"
    else
      "span4"
])

#NAVBAR CONTROLLER
.controller('welcomeCtrl', [
  '$scope'
   ($scope)->
])

.controller('TodoCtrl', [
  '$scope'

($scope) ->

  $scope.todos = [
    text: "learn angular"
    done: true
  ,
    text: "build an angular app"
    done: false
  ]

  $scope.addTodo = ->
    $scope.todos.push
      text: $scope.todoText
      done: false

    $scope.todoText = ""

  $scope.remaining = ->
    count = 0
    angular.forEach $scope.todos, (todo) ->
      count += (if todo.done then 0 else 1)

    count

  $scope.archive = ->
    oldTodos = $scope.todos
    $scope.todos = []
    angular.forEach oldTodos, (todo) ->
      $scope.todos.push todo  unless todo.done

])

