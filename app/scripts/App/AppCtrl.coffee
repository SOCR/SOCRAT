'use strict'

module.extend = class AppCtrl

  constructor: (@$scope, @$location, @$resource, @$rootScope) ->
    console.log 'controller block for AppCtrl'

    # create a list of modules for Tools tab dropdown
    @menu = []

    # listening to all changes in the view
    @$scope.$on 'change in view', =>
      @$scope.$broadcast 'update view', null

    @$scope.$on 'change in showStates', (obj, data) =>
      console.log 'change in showStates heard!'
      @$scope.$broadcast 'update showStates', data

    @$scope.$on 'update handsontable', (obj, data) =>
      console.log 'update in handsontable'
      @$scope.$broadcast data.purpose + ':load data to handsontable', data

    # listen on message from App.run block to register Tools in menu
    @$scope.$on 'app:set_menu', (event, data) =>
      console.log 'app: creating menu'
#      @menu = data

      @menu = [
        id: 'rawdata'
        name: 'Raw Data'
        type: 'text',
        url: '/getData'
      ,
        id: 'wrangler'
        name: 'Wrangle Data'
        type: 'text',
        url: '/wrangleData'
      ,
        data[0]
      ]

    # request Tools list from App.run
    @$rootScope.$broadcast 'app:get_menu'

    @username = 'Guest'
    @$scope.$watch '$location.path()', (path) =>
      @activeNavId = path || '/'

    # getClass compares the current url with the id.
    # If the current url starts with the id it returns 'active'
    # otherwise it will return '' an empty string. E.g.
    #
    #   # current url = '/products/1'
    #   getClass('/products') # returns 'active'
    #   getClass('/orders') # returns ''
    #

#  getNavbar: () ->
#    console.log 'GET NAVBAR'
#    @navbar = require('partials/analysis-nav.jade')()
#    console.log @navbar
#    @navbar

  # uses the url to determine if the selected
  #  menu item should have the class active
  getClass: (id) ->
    console.log id
    if @activeNavId.substring(0, id.length) == id
      'active'
    else
      ''

AppCtrl.$inject = ['$scope', '$location', '$resource', '$rootScope']

angular.module 'app_controllers', ['app_mediator']
  .controller 'AppCtrl', AppCtrl


