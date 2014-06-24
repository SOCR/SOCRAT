'use strict'

# jasmine specs for core

describe 'Core module', ->

  moduleId = 'myId'
  validModule = (sb) ->
    init: (opt, done) -> setTimeout (-> done()), 0
    destroy: (done) -> setTimeout (-> done()), 0
    msgList:
      outgoing: ['0']
      incoming: ['1']
      scope: ['validModuleScope']

# Create mock module and overriding services
  angular.module('app_mocks', [])
    .factory 'Sandbox', ->
      (_core, _instanceId, _options = {}) ->
        @core = @
        @instanceId = _instanceId
        @options = {}

    .service 'pubSub', ->
      @events = []
      @publish = (event) =>
          console.log 'pubSub: published'
          console.log event
          console.log @events[0].listener
          result = (item.listener(item.msg) for item in @events when item.msg is event.msg)
      @subscribe = (event) =>
        @events.push event
        console.log 'pubSub: subscribed'
        console.log @events
      @unsubscribe = ->
      publish: @publish
      subscribe: @subscribe
      unsubscribe: @unsubscribe

    .service('eventMngr', [
      'pubSub'
      'utils'
      (pubSub, utils) ->
        @incomeCallbacks = {}
        @eventManager = (msg, data) ->
          try
            _data = @incomeCallbacks[msg] data
          catch e
            console.log e.message
        @subscribeForEvents = (events, listnrList...) ->
          listnrList ?= @eventManager

          for i, msg of events.msgList
            console.log msg
            console.log pubSub.subscribe
            pubSub.subscribe
              msg: msg
            # checking if array of listeners was passes as a parameter
              listener: if utils.typeIsArray listnrList then listnrList[i] else listnrList
              msgScope: events.scope
        subscribeForEvents: @subscribeForEvents
        publish: pubSub.publish
        subscribe: pubSub.subscribe
    ])

  beforeEach ->
    module 'app_core'
    module 'app_mocks'

  describe 'provides service $core containing methods:', ->

    beforeEach ->
      inject (core) ->
        core.stop moduleId
        core.unregister moduleId

    describe 'register function', ->

      it 'should register valid module', ->
        inject (core) ->
          (expect core.register(moduleId, validModule)).toBeTruthy()

      it 'should not register module if the module creator is an object', ->
        inject (core) ->
          (expect core.register(moduleId, {})).toBeFalsy()

      it 'should not register module if the module creator does not return an object', ->
        inject (core) ->
          (expect core.register(moduleId, -> 'I\'m not an object')).toBeFalsy()

      it 'should not register module if the created module object has not the functions init and destroy', ->
        inject (core) ->
          (expect core.register(moduleId, ->)).toBeFalsy()

      it 'should register module if option parameter is an object', ->
        inject (core) ->
          (expect core.register(moduleId, validModule, {})).toBeTruthy()

      it 'should not register module if the option parameter is not an object', ->
        inject (core) ->
          (expect core.register(moduleId, validModule, 'I\'m not an object')).toBeFalsy()

      it 'should not register module if module already exits', ->
        inject (core) ->
          (expect core.register(moduleId, validModule)).toBeTruthy()
          (expect core.register(moduleId, validModule)).toBeFalsy()

    describe 'unregister function', ->

      it 'should unregister registered module', ->
        inject (core) ->
          (expect core.register(moduleId, validModule)).toBeTruthy()
          (expect core.unregister moduleId).toBeTruthy()
          (expect core.start moduleId).toBeFalsy()

    describe 'unregisterAll function', ->

      it 'should unregister all modules', ->
        inject (core) ->
          (expect core.register moduleId, validModule).toBeTruthy()
          (expect core.register 'module2', validModule).toBeTruthy()
          core.unregisterAll()
          (expect core.start moduleId).toBeFalsy()
          (expect core.start 'module2').toBeFalsy()

    describe 'start function', ->

      foo =
        cb1: () ->

      beforeEach ->
        inject (core) ->
          core.register moduleId, validModule

      it 'should not start module if invalid name was passed', ->
        inject (core) ->
          (expect core.start 123).toBeFalsy()
          (expect core.start ->).toBeFalsy()
          (expect core.start []).toBeFalsy()

      it 'should start module if valid name was passed', ->
        inject (core) ->
#          core.register moduleId, validModule
          (expect core.start moduleId).toBeTruthy()

      it 'should start module if empty parameters object was passed', ->
        inject (core) ->
          (expect core.start moduleId, {}).toBeTruthy()

      it 'should return false if second parameter is a number', ->
        inject (core) ->
          (expect core.start moduleId, 123).toBeFalsy()

      it 'should return false if module does not exist', ->
        inject (core) ->
          (expect core.start 'foo').toBeFalsy()

      it 'should return true if module exist', ->
        inject (core) ->
          (expect core.start moduleId).toBeTruthy()

      it 'should return false if instance was aleready started', ->
        inject (core) ->
          core.start 'myId'
          (expect core.start moduleId).toBeFalsy()

      it 'should pass the options', (done) ->
        inject (core) ->
          mod = (sb) ->
            init: (opt) ->
              (expect typeof opt).toEqual 'object'
              (expect opt.foo).toEqual 'bar'
              done()
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']
          core.register 'foo', mod
          core.start 'foo', options:
            {foo: 'bar'}

      it 'should call the callback function after the initialization', (done) ->
        inject (core) ->
          x = 0
          cb = -> (expect x).toBe(2); done()

          core.register 'anId', (sb) ->
            init: (opt, fini) ->
              setTimeout (-> x = 2; fini()), 0
              x = 1
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['idScope']

          core.start 'anId', { callback: cb }

      it 'should call the callback immediately if no callback was defined', ->
        inject (core) ->
          spyOn foo, 'cb1'
          mod1 = (sb) ->
            init: (opt) ->
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['idScope']
          (expect core.register 'anId', mod1).toBeTruthy()
          core.start 'anId', { callback: foo.cb1 }
          (expect foo.cb1).toHaveBeenCalled()

      it 'should call the callback function with an error if an error occurs', () ->
        inject (core) ->
          spyOn foo, 'cb1'

          mod1 = (sb) ->
            init: ->
              foo.cb1()
              thisWillProduceAnError()
            destroy: ->
            msgList:
              outgoing: ['a']
              incoming: ['b']
              scope: ['fooScope']

          (expect core.register 'anId', mod1).toBeTruthy()
          (expect core.start 'anId', { callback: (err) ->
            (expect foo.cb1).toHaveBeenCalled()
            (expect err.message).toEqual 'could not start module: thisWillProduceAnError is not defined'
          }).toBeFalsy()

      it 'should start a separate instance', ->
        inject (core) ->
          spyOn foo, 'cb1'
          mod1 = (sb) ->
            init: -> foo.cb1()
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          (expect core.register 'separate', mod1).toBeTruthy()
          core.start 'separate', { instanceId: 'instance' }
          (expect foo.cb1).toHaveBeenCalled()

      it 'should fire event in response to registered module according to event map', () ->
        inject (core, pubSub) ->
          spyOn foo, 'cb1'

          mod1 = (sb) ->
            init: ->
              console.log "INIT HERE"
              sb.subscribe
                msg: 'b'
                listener: ->
                  foo.cb1()
                msgScope: ['fooScope']
              sb.publish
                msg: 'a'
                data: ''
                msgScope: ['fooScope']
            destroy: ->
            msgList:
              outgoing: ['a']
              incoming: ['b']
              scope: ['fooScope']

          map = [
            msgFrom: 'a'
            scopeFrom: ['fooScope']
            msgTo: 'b'
            scopeTo: ['fooScope']
          ]

          core.setEventsMapping map
          (expect core.register 'anId', mod1).toBeTruthy()
          (expect core.start('anId', { callback: (err) ->
            (expect foo.cb1).toHaveBeenCalled()
          })).toBeTruthy()


    describe 'stop function', ->

      it 'should call the callback afterwards', (done) ->
        inject (core) ->
          (expect core.register moduleId, validModule).toBeTruthy()
          (expect core.start moduleId).toBeTruthy()
          (expect core.stop moduleId, done).toBeTruthy()

      it 'should support synchronous stopping', ->
        inject (core) ->
          mod = (sb) ->
            init: ->
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']
          end = false
          (expect core.register moduleId, mod).toBeTruthy()
          (expect core.start moduleId).toBeTruthy()
          (expect core.stop moduleId, -> end = true).toBeTruthy()
          (expect end).toEqual true

    describe 'startAll function', ->

      foo = {}

      beforeEach ->
        inject (core) ->
          core.stopAll()
          core.unregisterAll()
          foo =
            cb1: ->
            cb2: ->
            cb3: ->
            finished: ->

      it 'instantiates and starts all available modules', ->
        inject (core) ->
          spyOn foo, 'cb1'
          spyOn foo, 'cb2'

          mod1 = (sb) ->
            init: -> foo.cb1()
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          mod2 = (sb) ->
            init: -> foo.cb2()
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          (expect core.register 'first', mod1 ).toBeTruthy()
          (expect core.register 'second', mod2).toBeTruthy()

          (expect foo.cb1).not.toHaveBeenCalled()
          (expect foo.cb2).not.toHaveBeenCalled()

          (expect core.startAll()).toBeTruthy()
          (expect foo.cb1).toHaveBeenCalled()
          (expect foo.cb2).toHaveBeenCalled()

      it 'starts all modules of the passed array', ->
        inject (core) ->
          spyOn foo, 'cb1'
          spyOn foo, 'cb2'
          spyOn foo, 'cb3'

          mod1 = (sb) ->
            init: -> foo.cb1()
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          mod2 = (sb) ->
            init: -> foo.cb2()
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          mod3 = (sb) ->
            init: -> foo.cb3()
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          core.stopAll()
          core.unregisterAll()

          (expect core.register 'first', mod1 ).toBeTruthy()
          (expect core.register 'second',mod2 ).toBeTruthy()
          (expect core.register 'third', mod3 ).toBeTruthy()

          (expect foo.cb1).not.toHaveBeenCalled()
          (expect foo.cb2).not.toHaveBeenCalled()
          (expect foo.cb3).not.toHaveBeenCalled()

          (expect core.startAll ['first','third']).toBeTruthy()
          (expect foo.cb1).toHaveBeenCalled()
          (expect foo.cb2).not.toHaveBeenCalled()
          (expect foo.cb3).toHaveBeenCalled()

      it 'calls the callback function after all modules have started', (done) ->
        inject (core) ->
          spyOn foo, 'cb1'

          sync = (sb) ->
            init: (opt)->
              (expect foo.cb1).not.toHaveBeenCalled()
              foo.cb1()
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          pseudoAsync = (sb) ->
            init: (opt)->
              (expect foo.cb1.calls.count()).toEqual 1
              foo.cb1()
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          async = (sb) ->
            # as it is asyncronous, init function should take 2 parameters
            init: (opt, cb) ->
              setTimeout (->
                (expect foo.cb1.calls.count()).toEqual 2
                foo.cb1()
                done()
              ), 0

            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          core.register 'first', sync
          core.register 'second', async
          core.register 'third', pseudoAsync

          (expect core.startAll ->
            (expect foo.cb1.calls.count()).toEqual 3
            done()
          ).toBeTruthy()

      it 'calls the callback after defined modules have started', (done) ->
        inject (core) ->
          spyOn foo, 'finished'
          spyOn foo, 'cb1'
          spyOn foo, 'cb2'

          mod1 = (sb) ->
            init: (opt, done)->
              setTimeout (->done()), 0
              (expect foo.finished).not.toHaveBeenCalled()
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          mod2 = (sb) ->
            init: (opt, done) ->
              setTimeout (-> done()), 0
              (expect foo.finished).not.toHaveBeenCalled()
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          core.register 'first', mod1, { callback: foo.cb1 }
          core.register 'second', mod2, { callback: foo.cb2 }

          (expect core.startAll ['first','second'], ->
            foo.finished()
            (expect foo.cb1).toHaveBeenCalled()
            (expect foo.cb2).toHaveBeenCalled()
            done()
          ).toBeTruthy()

      it 'calls the callback with an error if one or more modules couldn\'t start', (done) ->
         inject (core) ->
           spyOn foo, 'cb1'
           spyOn foo, 'cb2'
           mod1 = (sb) ->
             init: -> foo.cb1(); thisIsAnInvalidMethod()
             destroy: ->
             msgList:
               outgoing: ['0']
               incoming: ['1']
               scope: ['fooScope']
           mod2 = (sb) ->
             init: -> foo.cb2()
             destroy: ->
             msgList:
               outgoing: ['0']
               incoming: ['1']
               scope: ['fooScope']
           core.register 'invalid', mod1
           core.register 'valid', mod2
           core.startAll ['invalid', 'valid'], (err) ->
             (expect foo.cb1).toHaveBeenCalled()
             (expect foo.cb2).toHaveBeenCalled()
             (expect err.message).toEqual 'errors occoured in the following modules: \'invalid\''
             done()

      it 'calls the callback with an error if one or more modules don\'t exist', () ->
        inject (core) ->
          spyOn foo, 'cb2'
          mod = (sb) ->
            init: (opt)->
              foo.cb2()
              setTimeout (-> ), 0
            destroy: ->
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']
          core.register 'valid', validModule
          core.register 'x', mod
          finished = (err) ->
            console.log err
            (expect err).toEqual "these modules don't exist: 'invalid', 'y'"
          mods = ['valid', 'invalid', 'x', 'y']
          (expect core.startAll(mods, @finished)).toBeFalsy()
          (expect foo.cb2).toHaveBeenCalled()

      it 'calls the callback without an error if module array is empty', ->
        inject (core) ->
          spyOn foo, 'cb1'
          finished = (err) ->
            (expect err).toEqual null
            foo.cb1()
          (expect core.startAll [], finished).toBeTruthy()
          (expect foo.cb1).toHaveBeenCalled()

    describe 'stopAll function', ->

      foo = {}

      beforeEach ->
        inject (core) ->
          core.stop moduleId
          core.unregister moduleId
          foo =
            cb1: ->
            cb2: ->
            cb3: ->
            finished: ->

      it 'should stop all running instances', ->
        inject (core) ->
          spyOn foo, 'cb1'

          mod1 = (sb) ->
            init: ->
            destroy: -> foo.cb1()
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']

          core.register moduleId, mod1

          core.start moduleId, { instanceId: 'a' }
          core.start moduleId, { instanceId: 'b' }

          (expect core.stopAll()).toBeTruthy()
          (expect foo.cb1.calls.count()).toEqual 2

      it 'should call the callback afterwards', (done) ->
        inject (core) ->
          (expect core.register moduleId, validModule).toBeTruthy()
          (expect core.start moduleId).toBeTruthy()
          (expect core.start moduleId, instanceId: 'valid').toBeTruthy()
          (expect core.stopAll done).toBeTruthy()

      it 'should call the callback if not destroyed in a asynchronous way', (done) ->
        inject (core) ->
          spyOn foo, 'cb1'
          mod = (sb) ->
            init: ->
            destroy: -> foo.cb1()
            msgList:
              outgoing: ['0']
              incoming: ['1']
              scope: ['fooScope']
          (expect core.register 'syncDestroy', mod).toBeTruthy()
          (expect core.start 'syncDestroy').toBeTruthy()
          (expect core.start 'syncDestroy', instanceId: 'second').toBeTruthy()
          (expect core.stopAll done).toBeTruthy()

    describe 'setEventsMapping function', ->

      it 'should set event map if it\'s an object', ->
        inject (core,$exceptionHandler) ->

          invalidMap = 5
          validMap = [
            msgFrom: '111'
            scopeFrom: ['0']
            msgTo: '123'
            scopeTo: ['1']
          ,
            msgFrom: '234'
            scopeFrom: ['1']
            msgTo: '000'
            scopeTo: ['0']
          ]
          try
            core.setEventsMapping invalidMap
          catch e
            expect(e.message).toEqual 'event map has to be a object'

          (expect core.setEventsMapping validMap).toBeTruthy()


#    describe 'onModuleState function', ->
#
#      beforeEach ->
#        core.register 'mod', (sb) ->
#          init: ->
#          destroy: ->
#
#      it 'calls a registered method on instatiation', (done) ->
#        fn = (data, channel) ->
#          (expect channel).toEqual 'instantiate/mod'
#        fn2 = (data, channel) ->
#          (expect channel).toEqual 'instantiate/_always'
#          done()
#        core.onModuleState 'instantiate', fn, 'mod'
#        core.onModuleState 'instantiate', fn2
#        core.start 'mod'
#
#      it 'calls a registered method on destruction', (done) ->
#        fn = (data, channel) ->
#          (expect channel).toEqual 'destroy/mod'
#          done()
#        core.onModuleState 'destroy', fn, 'mod'
#        core.start 'mod'
#        core.stop 'mod'

    describe 'list methods', ->

      beforeEach ->
        inject (core) ->
          core.stopAll()
          core.register moduleId, validModule

      it 'has an lsModules method', ->
        inject (core) ->
          (expect core.lsModules()).toEqual [moduleId]

      it 'has an lsInstances method', ->
        inject (core) ->
          (expect typeof core.lsInstances).toEqual 'function'
          (expect core.lsInstances()).toEqual []
          (expect core.start moduleId ).toBeTruthy()
          (expect core.lsInstances()).toEqual [moduleId]
          (expect core.start moduleId, instanceId: 'test' ).toBeTruthy()
          (expect core.lsInstances()).toEqual [moduleId, 'test']
          (expect core.stop moduleId).toBeTruthy()
          (expect core.lsInstances()).toEqual ['test']

