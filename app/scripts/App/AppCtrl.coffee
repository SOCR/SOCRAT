'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

appControllers = angular.module 'app_controllers'

module.extend = class AppCtrl extends BaseCtrl
  @register appControllers
  @inject '$scope', '$location', '$resource', '$rootScope', 'AppVersion'

  initialize: ->

    # app version
    @version = @AppVersion.version

    # create a list of modules for Tools tab dropdown
    @menu = []

    # listening to all changes in the view
    @$scope.$on 'change in view', =>
      @$scope.$broadcast 'update view', null

    # listen on message from App.run block to register Tools in menu
    @$scope.$on 'app:set_menu', (event, data) =>
      console.log 'app: creating menu'
      @menu = data

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

  getNavbar: () ->
    @navbar = require('partials/analysis-nav.jade')()
    @navbar

  # uses the url to determine if the selected
  #  menu item should have the class active
  getClass: (id) ->
    if @activeNavId.substring(0, id.length) == id
      'active'
    else
      ''
