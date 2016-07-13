'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'
AppMessageMap = require 'scripts/App/AppMessageMap.coffee'

###
# @name AppRun
# @desc Class for run block of application module
###

module.exports = class AppRun

  menu: []

  constructor: (@modules, @runModuleNames) ->

  runModules: (core, runServices) ->
    for module, idx in @runModuleNames
      if core.register module, runServices[idx]
        core.start module

  buildMenu: () ->

    createItem = (module) ->
        item = null
        # check if single module or group
        if module instanceof Module
          # check if module has state
          if module.state?.name and module.state.url
            # add module to menu
            item =
              id: module.id
              name: module.state.name
              url: module.state.url
              type: 'text'
        # if collection of modules, recursively create
        else
          [group, groupName] = ([v, k] for k, v of module)[0]
          item =
            name: groupName
            type: 'group'
            items: (createItem el for el in group)
        return item

    for module in @modules
      item = createItem module
      if item
        @menu.push item

  getRun: ($rootScope, core, runServices) ->

    console.log 'APP RUN'

    core.setEventsMapping new AppMessageMap()

    # TODO: recover core.register
    @runModules core, runServices

    @buildMenu()

    # subscribe for request from MainCtrl for list of tool modules
    $rootScope.$on 'app:get_menu', =>
      $rootScope.$broadcast 'app:set_menu', @menu

    $rootScope.$on "$stateChangeSuccess", (scope, next, change) ->
      console.log 'APP: state change: '
      console.log arguments

    console.log 'run block of app module'

