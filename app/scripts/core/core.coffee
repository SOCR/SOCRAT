'use strict'

#app.core module contains

core = angular.module('app_core', [
  'app_eventMngr'
  'app_sandbox'
  'app_errorMngr'
  'app_utils'
])

  .factory 'core', [
    'eventMngr'
    'Sandbox'
#    '$exceptionHandler'
    'utils'
#    (mediator, Sandbox, $exceptionHandler, utils) ->
    (eventMngr, Sandbox, utils) ->

      _modules = {}
      _instances = {}
      _instanceOpts = {}
      _map = {}
#      _plugins = {}

      _checkType = (type, val, name) ->
        # TODO: change to $exceptionHandler or return false anf throw exception in caller
#        console.log 'CORE: checkType: ' + "#{name} has to be a #{type}"
        if typeof val isnt type and utils.typeIsArray(val) isnt true
          console.log 'CORE: checkType: ' + "#{name} is not a #{type}"
          throw new TypeError "#{name} has to be a #{type}"

#      # registers a function that gets executed when a module instantiated.
#      _onModuleState = (state, fn, moduleId = '_always') ->
#        _checkType 'function', fn, 'parameter'
#        moduleStates.on '#{state}/#{moduleId}', fn, @

      _getInstanceOptions = (instanceId, module, opt) ->
        # Merge default options and instance options and start options,
        # without modifying the defaults.
        o = {}

        # first copy default module options
        o[key] = val for key, val of module.options

        # then copy instance options
        io = _instanceOpts[instanceId]
        o[key] = val for key, val of io if io

        # and finally copy start options
        o[key] = val for key, val of opt if opt

        # return options
        o

      _createInstance = (moduleId, instanceId = moduleId, opt) ->
        module = _modules[moduleId]
        return _instances[instanceId] if _instances[instanceId]?
        iOpts = _getInstanceOptions.apply @, [instanceId, module, opt]


        sb = new Sandbox @, instanceId, iOpts
        utils.installFromTo eventMngr, sb

#        for i,p of plugins when p.sandbox?
#          plugin = new p.sandbox sb
#          sb[k] = v for own k,v of plugin
#          if typeof p.on is 'object'
#            for ev,cb of p.on when typeof cb is 'function'
#              _onModuleState ev, cb

        instance              = new module.creator sb
        instance.options      = iOpts
        instance.id           = instanceId
        _instances[instanceId] = instance

#        for n in [instanceId, '_always']
#          moduleStates.emit 'instantiate/#{n}'
        console.log 'CORE: created instance of ' + instance.id

        instance

      _addModule = (moduleId, creator, opt) ->
        _checkType 'string', moduleId, 'module ID'
        _checkType 'function', creator, 'creator'
        _checkType 'object', opt, 'option parameter'

        modObj = new creator()
        _checkType 'object', modObj, 'the return value of the creator'
        _checkType 'function', modObj.init, '"init" of the module'
        _checkType 'function', modObj.destroy, '"destroy" of the module'
        _checkType 'object', modObj.msgList, 'message list of the module'
        _checkType 'object', modObj.msgList.outgoing,
          'outcoming message list of the module'

        # TODO: change to $exceptionHandler
        if _modules[moduleId]?
          throw new TypeError "module #{moduleId} was already registered"

        _modules[moduleId] =
          creator: creator
          options: opt
          id: moduleId

        console.log 'CORE: module added: ' + moduleId

        true

      _register = (moduleId, creator, opt = {}) ->
        try
          _addModule.apply @, [moduleId, creator, opt]
        catch e
          console.log " CORE: could not register module" + moduleId
          console.error "could not register module #{moduleId}: #{e.message}"
          false

      # unregisters module or plugin
      _unregister = (id, type) ->
        if type[id]?
          delete type[id]
          return true
        false

      # unregisters all modules or plugins
      _unregisterAll = (type) -> _unregister id, type for id of type

      _setInstanceOptions = (instanceId, opt) ->
        _checkType 'string', instanceId, 'instance ID'
        _checkType 'object', opt, 'option parameter'
        _instanceOpts[instanceId] ?= {}
        _instanceOpts[instanceId][k] = v for k,v of opt


      _start = (moduleId, opt = {}) ->
        try
          _checkType 'string', moduleId, 'module ID'
          _checkType 'object', opt, 'second parameter'
          unless _modules[moduleId]?
            throw new Error "module doesn't exist: #{moduleId}"

          instance = _createInstance.apply @, [
            moduleId
            opt.instanceId
            opt.options
          ]

          if instance.running is true
            throw new Error 'module was already started'

          # subscription for module events
          # TODO: consider checking scope list for containing nothing else but moduleId and "all"
          if instance.msgList? and instance.msgList.outgoing? and moduleId in instance.msgList.scope
            eventMngr.subscribeForEvents
              msgList: instance.msgList.outgoing
              scope: [moduleId]
              # TODO: figure out context
              context: console
              , _redirectMsg

          # if the module wants to init in an asynchronous way
          if (utils.getArgumentNames instance.init).length >= 2
            # then define a callback
            instance.init instance.options, (err) -> opt.callback? err
          else
            # else call the callback directly after initialisation
            instance.init instance.options
            opt.callback? null

          instance.running = true
          console.log 'CORE: started module ' + moduleId
          true

        catch e
          console.log "CORE: could not start module: #{e.message}"
          opt.callback? new Error "could not start module: #{e.message}"
          false

      _startAll = (cb, opt) ->

        if cb instanceof Array
          mods = cb; cb = opt; opt = null
          valid = (id for id in mods when _modules[id]?)
        else
          mods = valid = (id for id of _modules)

        if valid.length is mods.length is 0
          cb? null
          return true
        else if valid.length isnt mods.length
          invalid = ("'#{id}'" for id in mods when not (id in valid))
          invalidErr = new Error "these modules don't exist: #{invalid}"

        startAction = (m, next) ->
          o = {}
          modOpts = _modules[m].options
          o[k] = v for own k,v of modOpts when v
          o.callback = (err) ->
            modOpts.callback? err
            next err
          _start m, o

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

      _stop = (id, cb) ->
        if instance = _instances[id]

#          mediator.off instance

          # if the module wants destroy in an asynchronous way
          if (utils.getArgumentNames instance.destroy).length >= 1
            # then define a callback
            instance.destroy (err) ->
              cb? err
          else
            # else call the callback directly after stopping
            instance.destroy()
            cb? null

#          for n in [id, '_always']
#            @moduleStates.off 'instantiate/#{n}'
#            @moduleStates.emit 'destroy/#{n}'

          # remove
          delete _instances[id]
          true
        else false

      _stopAll = (cb) ->
        utils.doForAll(
          (id for id of _instances)
          (=> _stop.apply @, arguments)
          cb
        )

      _ls = (o) -> (id for id, m of o)

#      _registerPlugin = (plugin) ->
#        try
#          _checkType 'object', plugin, 'plugin'
#          _checkType 'string', plugin.id, '"id" of plugin'
#
#          if typeof plugin.sandbox is 'function'
#            Sandbox::[k] ?= v for k, v of plugin.sandbox::
#
#          if typeof plugin.core is 'function'
#            Core::[k] ?= v for k,v of plugin.core::
#
#          if typeof plugin.core is 'object'
#            Core::[k] ?= v for k,v of plugin.core
#
#          if typeof plugin.base is 'object'
#            base[k] ?= v for k,v of plugin.base
#
#          plugins[plugin.id] = plugin
#          true
#
#        catch e
##          console.error e
#          false

      _setEventsMapping = (map) ->
        _checkType 'object', map, 'event map'
        _map = map
        true

      _redirectMsg = (msg, data) ->
        for o in _map when o.msgFrom is msg
          eventMngr.publish
            msg: o.msgTo
            data: data
            msgScope: o.scopeTo
          console.log 'CORE: redirect mgs ' + o.msgTo + 'to ' + o.scopeTo
          return true
        console.log 'CORE: no mapping in API for message: ' + o.msgTo
        false

      # External methods
      lsModules: -> _ls _modules
      lsInstances: -> _ls _instances
      register: -> _register.apply @, arguments
      # wrapping for unregistering module
      unregister: (id) -> _unregister id, _modules
      # wrapping for unregistering all modules
      unregisterAll: -> _unregisterAll _modules
      start: -> _start.apply @, arguments
      startAll: -> _startAll.apply @, arguments
      stop: -> _stop.apply @, arguments
      stopAll: -> _stopAll.apply  @, arguments
      setEventsMapping: -> _setEventsMapping.apply @, arguments
  ]
