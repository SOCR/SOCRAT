"use strict"

describe "app.db module", ->

# Create mock module and overriding services
  angular.module('app.mocks', [])
    .factory 'Sandbox', ->
      (_core, _instanceId, _options = {}) ->
        @core = @
        @instanceId = _instanceId
        @options = {}
    .service 'mediator', ->
      @events = [];
      @publish = (event) ->
        result = (item.cb() for item in @events when item.name is event.name)
      @subscribe = (event) ->
        @events.push event

  beforeEach ->
    module "app.db"
    module "app.mocks"

  describe "database service", ->

    colA = ["a","a","b","b","c"]
    colB = [0,1,2,3,4]
    colC = [12,3,42,4]
    table = [
      {name:"A", values:colA, type:"nominal"}
      {name:"B", values:colB, type:"numeric"}
    ]
    
    it "creates a table and returned object contains crud API", ->
      inject (database)->
        obj = database.create table,"test"
        expect(database.exists "test").toBeTruthy()
        expect(typeof obj).toEqual "object"
        expect(typeof obj.addColumn).toEqual "function"
        expect(typeof obj.removeColumn).toEqual "function"
        expect(typeof obj.addListener).toEqual "function"
        expect(typeof obj.create).toEqual "function"
        expect(typeof obj.destroy).toEqual "function"

    it "returns false when table already exists", ->
      inject (database)->
        database.create table,"test"
        expect(database.exists "test").toBeTruthy()
        expect(database.create table,"test").toBeFalsy()

    it "creates table and retrieves data", ->
      inject (database)->
        database.create table, "test"
        expect(database.get("test", "A").length).toEqual 5
        #getting columns
        expect(database.get "test", "A").toMatch [0,0,1,1,2]
        expect(database.get "test", "B").toMatch [0,1,2,3,4]
        #getting whole table
        expect(database.get("test")[0]).toMatch [0,0,1,1,2]
        expect(database.get("test")[1]).toMatch [0,1,2,3,4]

    it "append column to existing table and read it from the returned obj", ->
      inject (database)->
        database.create table, "test"
        database.addColumn "C", colC, "numeric", "test"
        expect(database.get "test", "C").toMatch [12,3,42,4]
        
    it "remove column from existing table ", ->
      inject (database)->
        database.create table, "test"
        database.removeColumn "B", "test"
        expect(database.get "test", "B").not.toBeDefined()
        expect(database.get "test", "A").toBeDefined()

    it "returns false if column doesnt exist", ->
      inject (database)->
        database.create table, "test"
        expect(database.removeColumn "B", "test1").toBeFalsy()
        expect(database.removeColumn "D", "test").toBeFalsy()

    it "add a listener to a table and trigger with model change", ->
      inject (database)->
        database.create table, "test"
        foo =
          cb : ->
        spyOn(foo,"cb")
        database.addListener
          table : "test"
          listener:foo.cb
        database.addColumn "C", colC, "numeric", "test"
        expect(foo.cb).toHaveBeenCalled()

    it "add listeners to a column and trigger with model change", ->
      inject (database)->
        database.create table, "test"
        foo =
          cb1 : ->
          cb2 : ->
        spyOn(foo,"cb1")
        spyOn(foo,"cb2")
        database.addListener
          table : "test"
          column: "C" 
          listener:foo.cb1
        database.addListener
          table : "test"
          column: "B" 
          listener:foo.cb2
        database.addColumn "C", colC, "numeric", "test"
        expect(foo.cb1).toHaveBeenCalled()
        expect(foo.cb2).not.toHaveBeenCalled()

    it "destroys a table if it exists", ->
      inject (database)->
        database.create table, "tab1"
        expect(database.destroy "tab1").toBeTruthy()
        expect(database.destroy "tab2").toBeFalsy()
        expect(database.exists "tab1").toBeFalsy()
        
    it "append data to column.", ->



