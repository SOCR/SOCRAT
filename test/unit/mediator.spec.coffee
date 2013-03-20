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
        console.log "TEST -- it should have a pubSub service"
        expect(pubSub).toBeDefined()

    it "is an accessible function",->
      inject (pubSub)->
        console.log "TEST -- it is an accessible function"
        (expect typeof pubSub.publish).toEqual "function"

    it "should publish to a channel", ->
      inject (pubSub)->
        console.log "TEST -- it should publish to a channel"
        foo =
          cb : -> 2
        spyOn(foo,"cb")
        pubSub.subscribe("test channel",foo.cb)
        pubSub.publish("test channel",12)
        expect(foo.cb).toHaveBeenCalledWith("test channel",12)

  describe "subscribe function", ->
    it "is an accessible function", ->
      inject (pubSub)->
        console.log "TEST -- it is an accessible function"
        (expect typeof pubSub.subscribe).toEqual "function"
    it "should subscribe to a channel", ->
      inject (pubSub)->
        console.log "TEST -- it should subscribe to a channel"
        expect(pubSub.subscribe("test channel",()->2)).toEqual(15)

    it "returns false if callback is not a function", ->
      inject (pubSub) ->
        console.log "TEST -- it returns false if callback is not a function"
        (expect pubSub.subscribe "test channel" , 345).toEqual false

    it "subscribes a function to several channels", ->
      inject (pubSub) ->
        console.log "TEST -- it subscribes a function to several channels"
        obj =
          cb1: ->
        spyOn(obj,"cb1")
        pubSub.subscribe ["a","b"], obj.cb1
        pubSub.publish "a", "foo"
        (expect obj.cb1.calls.length).toEqual 1
        pubSub.publish "b", "bar"
        (expect obj.cb1.calls.length).toEqual 2

    it "subscribes several functions to several channels", ->
      inject (pubSub) ->
        console.log "TEST -- it subscribes several functions to several channels"
        obj =
          cb1 : ->
          cb2 : ->
        spyOn(obj,"cb1")
        spyOn(obj,"cb2")
        pubSub.subscribe
          "a":obj.cb1
          "b":obj.cb2
        pubSub.publish "a", "foo"
        (expect obj.cb1.calls.length).toEqual 1
        (expect obj.cb2.calls.length).toEqual 0
        pubSub.publish "b", "bar"
        (expect obj.cb1.calls.length).toEqual 1
        (expect obj.cb2.calls.length).toEqual 1

  describe "unsubscribe function", ->

    it "removes a subscription from a channel", ->
      inject (pubSub)->
        console.log "TEST -- it should unsubscribe from a channel"
        pubSub.subscribe("test channel",()->2)
        expect(pubSub.unsubscribe(15)).toEqual(15)

    it "removes a cb function from all channels", ->
      inject (pubSub)->
        console.log "TEST -- it removes a cb function from all channels"
        pubSub.subscribe("test channel",()->2)
        expect(pubSub.unsubscribe(15)).toEqual(15)

#    it "removes all subscriptions from a channel", ->
#      inject (pubSub)->
#        console.log "TEST -- should unsubscribe from a channel"
#        pubSub.subscribe("test channel",()->2)
#        expect(pubSub.unsubscribe(15)).toEqual(15)