"use strict"

#jasmine specs

describe "Mediator", ->
  #load the module
  beforeEach module "app.mediator"
#  Alternate implementation for including the module and injecting the service.
####  $injector = angular.injector ["app.mediator"]
####  serviceMediator = $injector.get 'pubSub'
  describe "publish function" , ->
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
        spyOn(foo,"cb")
        pubSub.subscribe
          msg:"test message"
          listener:foo.cb
          msgScope:["test"]
        pubSub.publish
          msg:"test message"
          data:12
          msgScope:["test"]
        expect(foo.cb).toHaveBeenCalledWith("test message",12)

    it "calls the callback if defined", ->
      inject (pubSub)->
        foo =
          cb : ()->
          name: ""
          cb2:()->
            2
        spyOn(foo,"cb")
        pubSub.subscribe
          msg:"test message"
          listener:foo.cb2
          scope:foo
      # passing callback to publish
      # should the publish method also have context argument??
        pubSub.publish
          msg:"test message"
          data:12
          callback:(err)->
            if err?
              console.log err.message
            foo.cb()

        expect(foo.cb).toHaveBeenCalled()

    it "publishes a message locally within the angular module ", ()->
      inject (pubSub)->
        foo=
          cb1: ()->
          cb2: ()->
        # implement the module initialization
        # pass sandbox to a mock module
        # publish a test message locally
        spyOn(foo,"cb2")
        spyOn(foo,"cb1")
        pubSub.subscribe
          msg:"test message for amazingModule"
          listener:foo.cb1
          msgScope:["amazingModule"]
        #now that we have a listener subscribed to the message

        pubSub.subscribe
          msg:"test message for notSoAmazingModule"
          listener:foo.cb2
          msgScope:["notSoAmazingModule"]

        pubSub.publish
          msg:"test message for amazingModule"
          data:12
          msgScope:["amazingModule"]

        expect(foo.cb1).toHaveBeenCalledWith("test message for amazingModule",12)
        expect(foo.cb2).not.toHaveBeenCalled()


    it "returns false if there is no matching msg in the list", ->
      inject (pubSub)->
        pubSub.publish
          msg : "test message"
          listener: (err)->
            (expect err?).toBe false
          msgScope:["test"]

    it "calls the callback even if there are no subscribers", ->
      inject (pubSub)->
        result = pubSub.publish
          msg : "test message"
          callback: (err) ->
            (expect err?).toBe false
          msgScope:["test"]
        expect(result).toBe(false)


    it "passes the message to only scopes mentioned in the messageScope of publish", ->
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
        ).subscribe(
          msg: "test message"
          listener: foo.cb2
          msgScope: ["module"]
        ).subscribe
          msg: "test message"
          listener: foo.cb3
          msgScope: ["app"]

        # publish to same message in both the scopes i.e. "core" and "module"
        result = pubSub.publish
          msg:"test message"
          msgScope:["core","module"]
        expect(foo.cb1).toHaveBeenCalled()
        expect(foo.cb2).toHaveBeenCalled()
        expect(foo.cb3).not.toHaveBeenCalled()

  describe "subscribe function", ->
    it "is an accessible function", ->
      inject (pubSub)->
        (expect typeof pubSub.subscribe).toEqual "function"

    it "should return false when no msgScope is provided", ->
      inject (pubSub)->
        expect pubSub.subscribe
          msg:"test message"
          listener:()->
        .toEqual(false)

    it "should should subscribe to a message", ->
      inject (pubSub)->
        obj=pubSub.subscribe
          msg:"test message"
          listener:()->
          msgScope:["test"]
        expect(obj.subscribe).toBeDefined()
        expect(obj.publish).toBeDefined()
        expect(obj.unsubscribe).toBeDefined()

    it "returns false if callback is not a function", ->
      inject (pubSub) ->
        expect pubSub.subscribe
          msg:"test message"
          listener:345
          msgScope:["test"]
        .toEqual false

    it "subscribes a function to several messages", ->
      inject (pubSub) ->
        obj =
          cb1: ()->
        spyOn(obj,"cb1")
        # chaining pubSub methods
        pubSub.subscribe(
          msg:["a","b"]
          listener:obj.cb1
          msgScope:["test"]
        ).publish(
          msg:"b"
          data:"foo"
          msgScope:["test"]
        )
        (expect obj.cb1.calls.length).toEqual 1
        pubSub.publish
          msg:"b"
          data:"bar"
          msgScope:["test"]
        (expect obj.cb1.calls.length).toEqual 2

    it "subscribes several functions to several messages", ->
      inject (pubSub) ->
        obj =
          cb1 : ->
          cb2 : ->
        spyOn(obj,"cb1")
        spyOn(obj,"cb2")
        pubSub.subscribe
          msg:
            "a":obj.cb1
            "b":obj.cb2
          msgScope:["test"]
        pubSub.publish
          msg:"a"
          data:"foo"
          msgScope:["test"]
        (expect obj.cb1.calls.length).toEqual 1
        (expect obj.cb2.calls.length).toEqual 0
        pubSub.publish
          msg:"b"
          data:"foo"
          msgScope:["test"]
        (expect obj.cb1.calls.length).toEqual 1
        (expect obj.cb2.calls.length).toEqual 1

  describe "unsubscribe function", ->

#    it "removes a subscription from a message", ->
#      inject (pubSub)->
#        console.log "TEST -- it should unsubscribe from a message"
#        pubSub.subscribe
#          msg:"test message"
#          listener:()->2
#        expect(pubSub.unsubscribe(15)).toEqual(15)
#
#    it "removes a cb function from all messages", ->
#      inject (pubSub)->
#        console.log "TEST -- it removes a cb function from all messages"
#        pubSub.subscribe("test message",()->2)
#        expect(pubSub.unsubscribe(15)).toEqual(15)
#
#    it "removes all subscriptions from a message", ->
#      inject (pubSub)->
#        console.log "TEST -- should unsubscribe from a message"
#        pubSub.subscribe("test message",()->2)
#        expect(pubSub.unsubscribe(15)).toEqual(15)