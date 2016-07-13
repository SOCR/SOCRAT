'use strict'

require 'scripts/core/eventMngr.coffee'
require 'scripts/core/errorMngr.coffee'
require 'scripts/core/Sandbox.coffee'
require 'scripts/core/utils.coffee'

###
# @name Core
# @desc Class for registering and starting modules
###
module.exports = class Core
  @modules = {}
  @instances = {}
  @instanceOpts = {}
  @map = {}
  @BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

  constructor: (eventMngr, Sandbox, errorMngr, utils) ->
    log: console.log

  @checkType: (type, val, name) ->
    # TODO: change to $exceptionHandler or return false anf throw exception in caller
    if typeof val isnt type and utils.typeIsArray(val) isnt true
      console.log '%cCORE: checkType: ' + "#{name} is not a #{type}", 'color:red'
      throw new TypeError "#{name} has to be a #{type}"

  @getInstanceOptions: (instanceId, module, opt) =>
    # Merge default options and instance options and start options,
    # without modifying the defaults.
    o = {}

    # first copy default module options
    o[key] = val for key, val of module.options

    # then copy instance options
    io = @instanceOpts[instanceId]
    o[key] = val for key, val of io if io

    # and finally copy start options
    o[key] = val for key, val of opt if opt

    # return options
    o

  @createInstance: (moduleId, instanceId = moduleId, opt) =>
    module = @modules[moduleId]
    return @instances[instanceId] if @instances[instanceId]?
    iOpts = @getInstanceOptions.apply @, [instanceId, module, opt]

    sb = new @Sandbox @, instanceId, iOpts
    utils.installFromTo eventMngr, sb

    instance              = new module.creator sb
    instance.options      = iOpts
    instance.id           = instanceId
    @instances[instanceId] = instance

    console.log '%cCORE: created instance of ' + instance.id, 'color:red'

    instance

  @addModule: (moduleId, moduleObj, opt) =>
    @checkType 'string', moduleId, 'module ID'
    @checkType 'object', opt, 'option parameter'

    # check that module instance
    if moduleObj instanceof @BaseModuleInitService
      @checkType 'function', moduleObj.init, '"init" of the module'
      @checkType 'function', moduleObj.destroy, '"destroy" of the module'
      @checkType 'function', moduleObj.getMsgList, '"getMsgList" of the module'
      moduleMsgList = moduleObj.getMsgList()
      @checkType 'object', moduleMsgList, 'message list of the module'
      @checkType 'object', moduleMsgList.outgoing, 'outcoming message list of the module'

      # TODO: change to $exceptionHandler
      if @modules[moduleId]?
        throw new TypeError "module #{moduleId} was already registered"

      @modules[moduleId] =
        moduleObj: moduleObj
        options: opt
        id: moduleId

      console.log '%cCORE: module added: ' + moduleId, 'color:red'
      true

    else
      throw new TypeError "module #{moduleId}'s init service is invalid"
      false

  register: (moduleId, creator, opt = {}) ->
    try
      @constructor.addModule.apply @, [moduleId, creator, opt]
    catch e
      console.log "%cCORE: could not register module" + moduleId, 'color:red'
      console.error "could not register module #{moduleId}: #{e.message}"
      false

  # unregisters module or plugin
  @unregister: (id, type) ->
    if type[id]?
      delete type[id]
      return true
    false

  # unregisters all modules or plugins
  @unregisterAll: (type) -> @unregister id, type for id of type

  @setInstanceOptions: (instanceId, opt) ->
    @checkType 'string', instanceId, 'instance ID'
    @checkType 'object', opt, 'option parameter'
    @instanceOpts[instanceId] ?= {}
    @instanceOpts[instanceId][k] = v for k,v of opt

  start: (moduleId, opt = {}) =>
    checkType = @constructor.checkType
    try
      checkType 'string', moduleId, 'module ID'
      checkType 'object', opt, 'second parameter'
      unless @constructor.modules[moduleId]?
        throw new Error "module doesn't exist: #{moduleId}"

      instance = @constructor.createInstance.apply @, [
        moduleId
        opt.instanceId
        opt.options
      ]

      if instance.running is true
        throw new Error 'module was already started'

      # subscription for module events
      # TODO: consider checking scope list for containing nothing else but moduleId and "all"
      if instance.msgList? and instance.msgList.outgoing? and moduleId in instance.msgList.scope
        console.log '%cCORE: subscribing for messages from ' + moduleId, 'color:red'
        @eventMngr.subscribeForEvents
          msgList: instance.msgList.outgoing
          scope: [moduleId]
          # TODO: figure out context
          context: console
          , @redirectMsg

      # if the module wants to init in an asynchronous way
      if (@utils.getArgumentNames instance.init).length >= 2
        # then define a callback
        instance.init instance.options, (err) -> opt.callback? err
      else
        # else call the callback directly after initialisation
        instance.init instance.options
        opt.callback? null

      instance.running = true
      console.log '%cCORE: started module ' + moduleId, 'color:red'
      true

    catch e
      console.log "%cCORE: could not start module: #{e.message}",'color:red'
      opt.callback? new Error "could not start module: #{e.message}"
      false

  @startAll: (cb, opt) ->

    if cb instanceof Array
      mods = cb; cb = opt; opt = null
      valid = (id for id in mods when @modules[id]?)
    else
      mods = valid = (id for id of @modules)

    if valid.length is mods.length is 0
      cb? null
      return true
    else if valid.length isnt mods.length
      invalid = ("'#{id}'" for id in mods when not (id in valid))
      invalidErr = new Error "these modules don't exist: #{invalid}"

    startAction = (m, next) ->
      o = {}
      modOpts = @modules[m].options
      o[k] = v for own k,v of modOpts when v
      o.callback = (err) ->
        modOpts.callback? err
        next err
      @start m, o

    utils.doForAll(
      valid
      startAction
      (err) ->
        if err?.length > 0
          e = new Error "errors occoured in the following modules: " +
                        "#{("'#{valid[i]}'" for x,i in err when x?)}"
        cb? e or invalidErr
      true)

    not invalidErr?

  @stop: (id, cb) ->
    if instance = @instances[id]

      # if the module wants destroy in an asynchronous way
      if (utils.getArgumentNames instance.destroy).length >= 1
        # then define a callback
        instance.destroy (err) ->
          cb? err
      else
        # else call the callback directly after stopping
        instance.destroy()
        cb? null
      # remove
      delete @instances[id]
      true
    else false

  @stopAll: (cb) ->
    utils.doForAll(
      (id for id of @instances)
      (=> @stop.apply @, arguments)
      cb
    )

  @ls: (o) -> (id for id, m of o)

  # TODO: move to eventMngr
  setEventsMapping: (map) ->
    @constructor.checkType 'object', map, 'event map'
    @constructor.map = map
    true


# inject dependencies
Core.$inject = [
  'eventMngr'
  'Sandbox'
  'utils'
]

# create module and singleton service
angular
  .module('app_core', ['app_eventMngr', 'app_sandbox', 'app_errorMngr', 'app_utils'])
  .factory('app_core_service', -> new Core)
