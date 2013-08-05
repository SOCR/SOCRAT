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
    table = [
      {name:"A", values:colA, type:"nominal"}
      {name:"B", values:colB, type:"numeric"}
    ]
    
    it "creates a table and returned object contains crud API", ->
      inject (database)->
        obj = database.create table,"test"
        expect(typeof obj).toEqual "object"
        expect(typeof obj.addColumn).toEqual "function"
        expect(typeof obj.removeColumn).toEqual "function"
        expect(typeof obj.addListener).toEqual "function"
        expect(typeof obj.create).toEqual "function"
        expect(typeof obj.destroy).toEqual "function"

    it "creates table and retrieves data", ->
      inject (database)->
        obj = database.create table, "test"
        expect(obj.get("test", "A").length).toEqual 5
        #getting columns
        expect(obj.get "test", "A").toMatch [0,0,1,1,2]
        expect(obj.get "test", "B").toMatch [0,1,2,3,4]
        #getting whole table
        expect(obj.get("test")[0]).toMatch [0,0,1,1,2]
        expect(obj.get("test")[1]).toMatch [0,1,2,3,4]
        
    it "append column to existing table and read it from the returned obj", ->

    it "add a listener to a table and trigger with model change", ->

    it "add listener to column of a table.", ->

    it "listeners to column and table are triggered.", ->
      
    it "append data to column.", ->



