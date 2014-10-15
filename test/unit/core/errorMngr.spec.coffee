'use strict'

# jasmine specs for errorMngr
# Author: Selvam (selvam1991@gmail.com)

describe "errorMngr Module", ->

  err =
    message: "This error will be published!"
    type: 'error'
    priority: 1
    testFunc: ->
    display: true

  foo =
    cb1: ->
    cb2: ->
  beforeEach ->
    module "app_errorMngr"
    module "app_mocks"

  describe "$exceptionHandler service", ->

    it "contains the service", ->
      inject ($exceptionHandler)->
        expect($exceptionHandler).toBeTruthy()

    it "logs the error and publishes a message when display is true", ->
      inject ($exceptionHandler, pubSub)->
        spyOn foo, "cb1"
        # dummy function registered on the same message
        pubSub.subscribe
          msg: "Display error to frontend"
          msgScope: ["error"]
          listener: foo.cb1
        res = $exceptionHandler err
        #pubSub.unsubscribe()
        expect(foo.cb1).toHaveBeenCalled()

    it "logs the error and doesnt publishes message when display is false", ->
      inject ($exceptionHandler, pubSub)->
        spyOn foo,"cb1"
        # dummy function registered on the same message
        pubSub.subscribe
          msg: "Display error to fontend"
          msgScope: ["error"]
          listener: foo.cb1
        #error object with display = false
        dontShowError =
          message: "This error wont be published [but will still be logged]!"
          type: 'error'
          display: false
        $exceptionHandler dontShowError
        expect(foo.cb1).not.toHaveBeenCalled()

#    it "throws the error back when in debug mode ", ->

    it "sets the debugMode ", ->
      inject ($exceptionHandler, $log) ->
        #setting debug mode to OFF
        $exceptionHandler
          debug: 0
        $exceptionHandler err
        expect($log.error.logs).toEqual []
        #setting debug mode to ON
        $exceptionHandler
          debug: 1
        $exceptionHandler err
        expect($log.error.logs.pop()).toEqual [ 'This error will be published!' ]
