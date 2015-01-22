"use strict"

#jasmine specs

describe "Mediator", ->

  #load the module
  beforeEach module "app_mediator"

#  Alternate implementation for including the module and injecting the service.
#  $injector = angular.injector ["app.mediator"]
#  serviceMediator = $injector.get 'pubSub'

  describe "publish method" , ->

    it "should have a pubSub service",->
      inject (pubSub)->
        expect(pubSub).toBeDefined()

    it "is an accessible function",->
      inject (pubSub)->
      # How to check whether a function is accessbile??
        (expect typeof pubSub.publish).toEqual "function"

    it "should publish to a message", ->
      inject (pubSub)->
        foo =
          cb : -> 2
        spyOn foo, "cb"
        pubSub.subscribe
          msg: "test message"
          listener: foo.cb
          msgScope: ["test"]
        pubSub.publish
          msg: "test message"
          data: 12
          msgScope: ["test"]
        expect(foo.cb).toHaveBeenCalledWith("test message", 12)

    it "calls the callback passed, if defined", ->
      inject (pubSub)->
        foo =
          cb: ->
          name: ""
          cb2: ->
            2
        spyOn foo,"cb"
        pubSub.subscribe
          msg: "test message"
          listener: foo.cb2
          scope: foo
      # passing callback to publish
      # should the publish method also have context argument??
        pubSub.publish
          msg: "test message"
          data: 12
          callback: (err) ->
            if err?
              console.log err.message
            foo.cb()

        expect(foo.cb).toHaveBeenCalled()

    it "returns false if there is no matching msg in the mediator msg list", ->
      inject (pubSub)->
        pubSub.publish
          msg: "test message"
          listener: (err) ->
            (expect err?).toBe false
          msgScope: ["test"]

    it "calls the callback even if there are no subscribers", ->
      inject (pubSub)->
        result = pubSub.publish
          msg: "test message"
          callback: (err) ->
            (expect err?).toBe false
          msgScope: ["test"]
        expect(result).toBe(false)

    it "publishes message only to scopes mentioned in the msgScope passed with publish call", ->
      inject (pubSub)->
        foo =
          cb1 : ()->
          cb2 : ()->
          cb3 : ()->

        spyOn foo, "cb1"
        spyOn foo, "cb2"
        spyOn foo, "cb3"

        pubSub.subscribe(
          msg: "test message"
          listener: foo.cb1
          msgScope: ["core"]
        )
        pubSub.subscribe(
          msg: "test message"
          listener: foo.cb2
          msgScope: ["module"]
        )
        pubSub.subscribe
          msg: "test message"
          listener: foo.cb3
          msgScope: ["app"]

        # publish to same message in both the scopes i.e. "core" and "module"
        result = pubSub.publish
          msg: "test message"
          msgScope: ["core","module"]

        expect(foo.cb1).toHaveBeenCalled()
        expect(foo.cb2).toHaveBeenCalled()
        expect(foo.cb3).not.toHaveBeenCalled()

    it "returns false if msg is not string", ->
      inject (pubSub)->
        res = pubSub.subscribe
          msg: "String!"
          msgScope: ['test']
          listener: ()->
            console.log "listener is getting executed!!"
        res = pubSub.publish
          msg: ['not a string']
          msgScope: ['test']
        expect(res).toEqual false
        res = pubSub.publish
          msg: 'String!'
          msgScope: ['test']
        expect(typeof res).toEqual 'object'

    it "throws error if msgScope is absent or not an Array", ->
      inject (pubSub)->
        res = pubSub.subscribe
          msg: "test message"
          msgScope: ['test']
          listener: ()->
            console.log "listener is getting executed!!"

        expect(->
          pubSub.publish
            msg: "test message"
        ).toThrow new Error("msgScope is not defined")

        expect(->
          pubSub.publish
            msg: "test message"
            msgScope: null
        ).toThrow new Error("msgScope is not defined")

        expect(->
          pubSub.publish
            msg: "test message"
            msgScope: 'string'
        ).toThrow new Error("msgScope is not an Array instance")

        res = pubSub.publish
          msg: 'test message'
          msgScope:['test']
        expect(typeof res).toEqual 'object'

  describe "subscribe function", ->
    it "is an accessible function", ->
      inject (pubSub)->
        console.log "TEST -- it is an accessible function"
        (expect typeof pubSub.subscribe).toEqual "function"

    it "should return false when no msgScope is provided", ->
      inject (pubSub)->
        res = pubSub.subscribe
          msg: "test message"
          listener: ->
            console.log "listener is getting executed!!"
        expect(res).toEqual(false)

    it "should subscribe to a message", ->
      inject (pubSub) ->
        obj = pubSub.subscribe
          msg: "test message"
          listener: ->
          msgScope: ["test"]
        expect(obj['test message']['test']).toEqual 0

    it "returns false if callback is not a function", ->
      inject (pubSub) ->
        console.log "TEST -- it returns false if callback is not a function"
        res = pubSub.subscribe
          msg: "test message"
          listener: 345
          msgScope: ["test"]
        expect(res).toEqual false

    it "subscribes a function to several messages", ->
      inject (pubSub) ->
        console.log "TEST -- it subscribes a function to several messages"
        obj =
          cb1: ->
        spyOn obj, "cb1"
        # chaining pubSub methods
        pubSub.subscribe(
          msg: ["a", "b"]
          listener: obj.cb1
          msgScope: ["test"]
        ).publish(
          msg: "b"
          data: "foo"
          msgScope: ["test"]
        )
        (expect obj.cb1.calls.count()).toEqual 1
        pubSub.publish
          msg: "b"
          data: "bar"
          msgScope: ["test"]
        (expect obj.cb1.calls.count()).toEqual 2

    it "subscribes several functions to several messages", ->
      inject (pubSub) ->
        console.log "TEST -- it subscribes several functions to several messages"
        obj =
          cb1: ->
          cb2: ->
        spyOn obj,"cb1"
        spyOn obj,"cb2"
        pubSub.subscribe
          msg:
            "a": obj.cb1
            "b": obj.cb2
          msgScope: ["test"]
        pubSub.publish
          msg: "a"
          data: "foo"
          msgScope: ["test"]
        (expect obj.cb1.calls.count()).toEqual 1
        (expect obj.cb2.calls.count()).toEqual 0
        pubSub.publish
          msg: "b"
          data: "foo"
          msgScope: ["test"]
        (expect obj.cb1.calls.count()).toEqual 1
        (expect obj.cb2.calls.count()).toEqual 1

  describe "unsubscribe function", ->
    foo =
      cb: ->2
    it "removes a listener from the specified message", ->
      inject (pubSub)->
        console.log "TEST -- it should unsubscribe from a message"
        spyOn foo,"cb"
        token = pubSub.subscribe
          msg:"test message"
          msgScope:['test']
          listener:foo.cb

        pubSub.publish
          msg:"test message"
          msgScope:['test']
        expect(foo.cb).toHaveBeenCalled()
        expect(pubSub.unsubscribe(token)).toEqual true
        pubSub.publish
          msg:"test message"
          msgScope:['test']
        (expect foo.cb.calls.count()).toEqual 1

    it "returns false when incorrect msg is passed", ->
      inject (pubSub)->
        console.log "TEST -- returns false when incorrect msg is passed"
        token = pubSub.subscribe
          msg:"test message"
          msgScope:['test']
          listener:()->2
        token =
          'message with no listeners':{'test':0}
        expect(pubSub.unsubscribe(token)).toEqual false

