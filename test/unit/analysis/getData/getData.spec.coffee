"use strict"

describe "getData", ->
###
  Creating empty modules which the app.getData is dependent on i.e.
  ngGrid and ui.bootstrap.
###
  angular.module "ngGrid",[]
  angular.module "ui.bootstrap",[]
  beforeEach ->
    module "app.getData"


  describe "showState", ->
###
  ShowState is service for similar to accordion. For keeping only value as true
  at all times.
###
    it "should return false if input obj is not defined.", ->
      inject (showState)->
        expect(new showState()).toEqual({})

    it "should create showState object to supplied scope.", ->
      inject (showState,$rootScope)->
        scope = $rootScope.$new()
        ss = new showState(["div1","div2"],scope)
        expect(scope.showState).toBeDefined()
        expect(typeof scope.showState).toEqual("object")
        expect(Object.keys(scope.showState).length).toEqual(2)

    it "sets supplied showState[index] to false, and everything else to true.", ->
      inject (showState,$rootScope) ->
        scope = $rootScope.$new()
        ss = new showState ["div1","div2"],scope
        ss.set("div1")
        expect(scope.showState["div1"]).toBeFalsy()
        expect(scope.showState["div2"]).toBeTruthy()
