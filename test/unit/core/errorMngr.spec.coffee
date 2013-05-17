'use strict'

# jasmine specs for errorMngr
# Author: Selvam (selvam1991@gmail.com)

describe "errorMngr Module", ->

  err =
    message: "omg Error!"
    prioirity:1
    testFunc:()->
    display:true

  foo =
    cb1: ->
    cb2: ->
# extending mock module created in core.spec.coffee and overriding services
  angular.module("app.mocks")
    .factory 'pubSub', ->
      _cbList = []
      _addCb = (fn)->
        _cbList.push fn
      publish:(obj)->
        if typeof obj is 'object'
          for fn in _cbList
            fn.call()
          return true
        else
          return false
      subscribe:(obj)->
        if typeof obj is 'object'
          _addCb(obj.cb)
          return true
        else
          return false
      unsubscribe:()->
        #flushes the _cbList
        _cbList=[]
    .factory '$log', ->
      error: (msg)->
        foo.cb2()
      log: (msg)->
        foo.cb2()
      info: (msg)->
        foo.cb2()
      warn: (msg)->
        foo.cb2()
  beforeEach ->
    module "app.errorMngr"
    module "app.mocks"

  describe "$exceptionHandler service", ->

    it "contains the service", ->
      inject ($exceptionHandler)->
        expect($exceptionHandler).toBeTruthy()

    it "logs the error and publishes a message when display is true", ->
      inject ($exceptionHandler,pubSub)->
        spyOn foo,"cb1"
        # dummy function registered on the same message
        pubSub.subscribe
          msg:"Display error to fontend"
          msgScope:["error"]
          cb:foo.cb1
        $exceptionHandler err
        pubSub.unsubscribe()
        expect(foo.cb1).toHaveBeenCalled()

    it "logs the error and doesnt publishes message when display is false", ->
      inject ($exceptionHandler,pubSub)->
        spyOn foo,"cb1"
        # dummy function registered on the same message
        pubSub.subscribe
          msg:"Display error to fontend"
          msgScope:["error"]
          cb:foo.cb1
        #error object with display = false
        error =
          message: "omg Error!"
          display:false
        $exceptionHandler error
        expect(foo.cb1).not.toHaveBeenCalled()

#    it "throws the error back when in debug mode ", ->

    it "sets the debugMode ", ->
      inject ($exceptionHandler) ->
        #setting debug mode to OFF
        $exceptionHandler
          debug:0
        spyOn(foo,"cb2")
        $exceptionHandler err
        expect(foo.cb2).not.toHaveBeenCalled()
        #setting debug mode to ON
        $exceptionHandler
          debug:1
        $exceptionHandler err
        expect(foo.cb2).toHaveBeenCalled()
