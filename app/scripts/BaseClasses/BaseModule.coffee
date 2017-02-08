'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'
BaseModuleMsgService = require 'scripts/BaseClasses/BaseModuleMessageService.coffee'
BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

###
  @name Module
  @desc Base class for SOCRAT module prototyping
###
module.exports = class Module

  @INIT_SERVICE_SUFFIX: '_initService'
  @MSG_SERVICE_SUFFIX: '_msgService'
  @DATA_SERVICE_SUFFIX: '_dataService'
  @MSG_LIST_SUFFIX: '_msgList'

  constructor: (options) ->

    # parse passes module configuration
    if options.id?
      @id = options.id

      # add default services
      if options.components?
        @components = options.components
        @components.services[@id + @constructor.INIT_SERVICE_SUFFIX] = BaseModuleInitService
        @components.services[@id + @constructor.MSG_SERVICE_SUFFIX] = BaseModuleMsgService
        @components.services[@id + @constructor.DATA_SERVICE_SUFFIX] = BaseModuleDataService
      else
        @components = @constructor.defaultComponents

      @state = if options.state? then options.state else @constructor.defaultState
      @deps = if options.deps? then options.deps else []

      # add default and custom messages to module's message list
      @msgList = {}
      @msgList.incoming = [].concat @constructor.msgList.incoming
      @msgList.outgoing = [].concat @constructor.msgList.outgoing
      @msgList.scope = [@id]

      if options.msgList?
        @msgList.incoming = [@msgList.incoming..., options.msgList.incoming...] if options.msgList.incoming.length
        @msgList.outgoing = [@msgList.outgoing..., options.msgList.outgoing...] if options.msgList.outgoing.length

      # register a module
      module = angular.module @id, @deps

    else false

  @defaultComponents =
    services:
      initService: BaseModuleInitService
      messageService: BaseModuleMsgService
      dataService: BaseModuleDataService
    controllers: []
    directives: []
    runBlock: null
#
  @defaultState =
    id: null
    url: null
    views:
      main:
        template: null
      sidebar:
        template: null

  @msgList =
    incoming: ['save data', 'get data']
    outgoing: ['data saved', 'take data']
