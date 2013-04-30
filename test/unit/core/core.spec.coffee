'use strict'

# jasmine specs for core

describe 'Core module', ->

  moduleId = 'myId'
  validModule = (sb) ->
    init: (opt, done) -> setTimeout (-> done()), 0
    destroy: (done) -> setTimeout (-> done()), 0

# Create mock module and overriding services
  angular.module('app.mocks', [])
    .factory 'Sandbox', ->
      (_core, _instanceId, _options = {}) ->
        @core = @
        @instanceId = _instanceId
        @options = {}
    .service('pubSub', ->)

  beforeEach ->
    module 'app.core'
    module 'app.mocks'

  describe 'provides service $core', ->

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

#    describe 'unregisterAll function', ->
#
#      it 'should unregister all modules', ->
#        inject (core) ->
#          (expect core.register moduleId, validModule).toBeTruthy()
#          (expect core.register moduleId2, validModule).toBeTruthy()
#          core.unregisterAll()
#          (expect core.start moduleId).toBeFalsy()
#          (expect core.start moduleId2).toBeFalsy()

    describe 'start function', ->

      foo =
        cb1: ->

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
          core.register moduleId, validModule
          (expect core.start moduleId).toBeTruthy()

      it 'should start module if empty parameters object was passed', ->
        inject (core) ->
          (expect core.start moduleId, {}).toBeTruthy()

      it 'returns false if second parameter is a number', ->
        inject (core) ->
          (expect core.start moduleId, 123).toBeFalsy()

      it 'returns false if module does not exist', ->
        inject (core) ->
          (expect core.start 'foo').toBeFalsy()

      it 'returns true if module exist', ->
        inject (core) ->
          (expect core.start moduleId).toBeTruthy()

      it 'returns false if instance was aleready started', ->
        inject (core) ->
          core.start 'myId'
          (expect core.start moduleId).toBeFalsy()

      it 'passes the options', (done) ->
        inject (core) ->
          mod = (sb) ->
            init: (opt) ->
              (expect typeof opt).toEqual 'object'
              (expect opt.foo).toEqual 'bar'
              done()
            destroy: ->
          core.register 'foo', mod
          core.start 'foo', options:
            {foo: 'bar'}

      it 'calls the callback function after the initialization', (done) ->
        inject (core) ->
          x = 0
          cb = -> (expect x).toBe(2); done()

          core.register 'anId', (sb) ->
            init: (opt, fini) ->
              setTimeout (-> x = 2; fini()), 0
              x = 1
            destroy: ->

          core.start 'anId', { callback: cb }

      it 'calls the callback immediately if no callback was defined', ->
        inject (core) ->
          spyOn foo, 'cb1'
          mod1 = (sb) ->
            init: (opt) ->
            destroy: ->
          (expect core.register 'anId', mod1).toBeTruthy()
          core.start 'anId', { callback: foo.cb1 }
          (expect foo.cb1).toHaveBeenCalled()

      it 'calls the callback function with an error if an error occurs', (done) ->
        inject (core) ->
          spyOn foo, 'cb1'
          mod1 = (sb) ->
            init: ->
              foo.cb1()
              thisWillProduceAnError()
            destroy: ->
          (expect core.register 'anId', mod1).toBeTruthy()
          (expect core.start 'anId', { callback: (err) ->
            (expect foo.cb1).toHaveBeenCalled()
            (expect err.message).toEqual 'could not start module: thisWillProduceAnError is not defined'
            # TODO: fix context for done()
#            done()
          }).toBeFalsy()

      it 'starts a separate instance', ->
        inject (core) ->
          spyOn foo, 'cb1'
          mod1 = (sb) ->
            init: -> foo.cb1()
            destroy: ->

          (expect core.register 'separate', mod1).toBeTruthy()
          core.start 'separate', { instanceId: 'instance' }
          (expect foo.cb1).toHaveBeenCalled()

    describe 'stop function', ->

      it 'calls the callback afterwards', (done) ->
        inject (core) ->
          (expect core.register moduleId, validModule).toBeTruthy()
          (expect core.start moduleId).toBeTruthy()
          (expect core.stop moduleId, done).toBeTruthy()

      it 'supports synchronous stopping', ->
        inject (core) ->
          mod = (sb) ->
            init: ->
            destroy: ->
          end = false
          (expect core.register moduleId, mod).toBeTruthy()
          (expect core.start moduleId).toBeTruthy()
          (expect core.stop moduleId, -> end = true).toBeTruthy()
          (expect end).toEqual true
#
#    describe 'startAll function', ->
#
#      foo = {}
#
#      beforeEach ->
#        core.stopAll()
#        core.unregisterAll()
#        foo =
#          cb1: ->
#          cb2: ->
#          cb3: ->
#          finished: ->
#
#      it 'instantiates and starts all available modules', ->
#        spyOn foo, 'cb1'
#        spyOn foo, 'cb2'
#
#        mod1 = (sb) ->
#          init: -> foo.cb1()
#          destroy: ->
#
#        mod2 = (sb) ->
#          init: -> foo.cb2()
#          destroy: ->
#
#        (expect core.register 'first', mod1 ).toBeTruthy()
#        (expect core.register 'second', mod2).toBeTruthy()
#
#        (expect foo.cb1).not.toHaveBeenCalled()
#        (expect foo.cb2).not.toHaveBeenCalled()
#
#        (expect core.startAll()).toBeTruthy()
#        (expect foo.cb1).toHaveBeenCalled()
#        (expect foo.cb2).toHaveBeenCalled()
#
#      it 'starts all modules of the passed array', ->
#        spyOn foo, 'cb1'
#        spyOn foo, 'cb2'
#        spyOn foo, 'cb3'
#
#        mod1 = (sb) ->
#          init: -> foo.cb1()
#          destroy: ->
#
#        mod2 = (sb) ->
#          init: -> foo.cb2()
#          destroy: ->
#
#        mod3 = (sb) ->
#          init: -> foo.cb3()
#          destroy: ->
#
#        core.stopAll()
#        core.unregisterAll()
#
#        (expect core.register 'first', mod1 ).toBeTruthy()
#        (expect core.register 'second',mod2 ).toBeTruthy()
#        (expect core.register 'third', mod3 ).toBeTruthy()
#
#        (expect foo.cb1).not.toHaveBeenCalled()
#        (expect foo.cb2).not.toHaveBeenCalled()
#        (expect foo.cb3).not.toHaveBeenCalled()
#
#        (expect core.startAll ['first','third']).toBeTruthy()
#        (expect foo.cb1).toHaveBeenCalled()
#        (expect foo.cb2).not.toHaveBeenCalled()
#        (expect foo.cb3).toHaveBeenCalled()
#
#      it 'calls the callback function after all modules have started', (done) ->
#        spyOn foo, 'cb1'
#
#        sync = (sb) ->
#          init: (opt)->
#            (expect foo.cb1).not.toHaveBeenCalled()
#            foo.cb1()
#          destroy: ->
#
#        pseudoAsync = (sb) ->
#          init: (opt, done)->
#            (expect foo.cb1.callCount).toEqual 1
#            foo.cb1()
#            done()
#          destroy: ->
#
#        async = (sb) ->
#          init: (opt, done)->
#            setTimeout (->
#              (expect foo.cb1.callCount).toEqual 2
#              foo.cb1()
#              done()
#            ), 0
#          destroy: ->
#
#        core.register 'first', sync
#        core.register 'second', async
#        core.register 'third', pseudoAsync
#
#        (expect core.startAll ->
#          (expect foo.cb1.callCount).toEqual 3
#          done()
#        ).toBeTruthy()
#
#      it 'calls the callback after defined modules have started', (done) ->
#        spyOn foo, 'finished'
#        spyOn foo, 'cb1'
#        spyOn foo, 'cb2'
#
#        mod1 = (sb) ->
#          init: (opt, done)->
#            setTimeout (->done()), 0
#            (expect foo.finished).not.toHaveBeenCalled()
#          destroy: ->
#
#        mod2 = (sb) ->
#          init: (opt, done) ->
#            setTimeout (-> done()), 0
#            (expect foo.finished).not.toHaveBeenCalled()
#          destroy: ->
#
#        core.register 'first', mod1, { callback: foo.cb1 }
#        core.register 'second', mod2, { callback: foo.cb2 }
#
#        (expect core.startAll ['first','second'], ->
#          foo.finished()
#          (expect foo.cb1).toHaveBeenCalled()
#          (expect foo.cb2).toHaveBeenCalled()
#          done()
#        ).toBeTruthy()
#
#      it 'calls the callback with an error if one or more modules couldn\'t start', (done) ->
#        spyOn foo, 'cb1'
#        spyOn foo, 'cb2'
#        mod1 = (sb) ->
#          init: -> foo.cb1(); thisIsAnInvalidMethod()
#          destroy: ->
#        mod2 = (sb) ->
#          init: -> foo.cb2()
#          destroy: ->
#        core.register 'invalid', mod1
#        core.register 'valid', mod2
#        core.startAll ['invalid', 'valid'], (err) ->
#          (expect foo.cb1).toHaveBeenCalled()
#          (expect foo.cb2).toHaveBeenCalled()
#          (expect err.message).toEqual 'errors occoured in the following modules: "invalid"'
#          done()
#
#      it 'calls the callback with an error if one or more modules don\'t exist', (done) ->
#        spyOn foo, 'cb2'
#        mod = (sb) ->
#          init: (opt, done)->
#            foo.cb2()
#            setTimeout (-> done()), 0
#          destroy: ->
#        core.register 'valid', validModule
#        core.register 'x', mod
#        finished = (err) ->
#          (expect err.message).toEqual 'these modules don\'t exist: "invalid","y"'
#          done()
#        (expect core.startAll ['valid','invalid', 'x', 'y'], finished).toBeFalsy()
#        (expect foo.cb2).toHaveBeenCalled()
#
#      it 'calls the callback without an error if module array is empty', ->
#        spyOn foo, 'cb1'
#        finished = (err) ->
#          (expect err).toEqual null
#          foo.cb1()
#        (expect core.startAll [], finished).toBeTruthy()
#        (expect foo.cb1).toHaveBeenCalled()
#
#    describe 'stopAll function', ->
#
#      foo = {}
#
#      beforeEach ->
#        core.stopAll()
#        core.unregisterAll()
#        foo =
#          cb1: ->
#          cb2: ->
#          cb3: ->
#          finished: ->
#
#      it 'stops all running instances', ->
#        spyOn foo, 'cb1'
#
#        mod1 = (sb) ->
#          init: ->
#          destroy: -> foo.cb1()
#
#        core.register 'mod', mod1
#
#        core.start 'mod', { instanceId: 'a' }
#        core.start 'mod', { instanceId: 'b' }
#
#        (expect core.stopAll()).toBeTruthy()
#        (expect foo.cb1.callCount).toEqual 2
#
#      it 'calls the callback afterwards', (done) ->
#        (expect core.register 'valid', validModule).toBeTruthy()
#        (expect core.start 'valid').toBeTruthy()
#        (expect core.start 'valid', instanceId: 'valid2').toBeTruthy()
#        (expect core.stopAll done).toBeTruthy()
#
#      it 'calls the callback if not destroyed in a asynchronous way', (done) ->
#        spyOn foo, 'cb1'
#        mod = (sb) ->
#          init: ->
#          destroy: -> foo.cb1()
#        (expect core.register 'syncDestroy', mod).toBeTruthy()
#        (expect core.start 'syncDestroy').toBeTruthy()
#        (expect core.start 'syncDestroy', instanceId: 'second').toBeTruthy()
#        (expect core.stopAll done).toBeTruthy()
#
#    describe 'list methods', ->
#
#      foo = {}
#
#      beforeEach ->
#        core.stopAll()
#        core.register 'myModule', validModule
#
#      it 'has an lsModules method', ->
#        (expect typeof core.lsModules).toEqual 'function'
#        (expect core.lsModules()).toEqual ['myModule']
#
#      it 'has an lsInstances method', ->
#        (expect typeof core.lsInstances).toEqual 'function'
#        (expect core.lsInstances()).toEqual []
#        (expect core.start 'myModule' ).toBeTruthy()
#        (expect core.lsInstances()).toEqual ['myModule']
#        (expect core.start 'myModule', instanceId: 'test' ).toBeTruthy()
#        (expect core.lsInstances()).toEqual ['myModule', 'test']
#        (expect core.stop 'myModule').toBeTruthy()
#        (expect core.lsInstances()).toEqual ['test']
#
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



#    describe "list methods", ->
#
#      before ->
#        core.stopAll()
#        core.register "myModule", @validModule
#
#      it "has an lsModules method", ->
#        (expect typeof @core.lsModules).toEqual "function"
#        (expect @core.lsModules()).toEqual ["myModule"]
#
#      it "has an lsInstances method", ->
#        (expect typeof @core.lsInstances).toEqual "function"
#        (expect @core.lsInstances()).toEqual []
#        (expect @core.start "myModule" ).toBeTruthy()
#        (expect @core.lsInstances()).toEqual ["myModule"]
#        (expect @core.start "myModule", instanceId: "test" ).toBeTruthy()
#        (expect @core.lsInstances()).toEqual ["myModule", "test"]
#        (expect @core.stop "myModule").toBeTruthy()
#        (expect @core.lsInstances()).toEqual ["test"]