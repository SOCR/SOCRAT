"use strict"

describe "app.db module", ->
  colA = ["a","a","b","b","c"]
  colB = [0,1,2,3,4]
  colC = [12,3,42,4]
  table = [
    {name:"A", values:colA, type:"nominal"}
    {name:"B", values:colB, type:"numeric"}
  ]

# Create mock module and overriding services
  angular.module('app.mocks', [])
    .factory 'Sandbox', ->
      (_core, _instanceId, _options = {}) ->
        @core = @
        @instanceId = _instanceId
        @options = {}
    .service 'pubSub', ->
      @events = [];
      @publish = (event) ->
        result = (item.listener(event.msg,event.data) for item in @events when item.msg is event.msg)
      @subscribe = (event) ->
        @events.push event

  beforeEach ->
    module "app.db"
    module "app.mocks"

  describe "database service", ->

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
      # method doesnt exist yet. Will do this when the method is implemented.

    it "performs (SQL like)filtering queries using where", ->
      inject (database)->
        database.create table, "tab1"
        tab2 = database.where (table,row)->
            table.get("B", row) > 1
          , "tab1"
        expect(tab2[0]).toMatch [1,1,2]
        expect(tab2[1]).toMatch [2,3,4]

    it "performs (SQL like)aggregating queries using query(same as dense_query)", ->
      inject (database)->
        database.create table, "tab1"
        tab2 = database.dense_query
            dims:[0]
            vals:[dv.count(), dv.sum(1)]
          , "tab1"
        expect(tab2).toMatch [["a","b","c"], [2,2,1], [1,5,4]]
        tab3 = database.dense_query
            dims:[0]
            vals:[dv.count(), dv.sum(1)]
            code:true
          , "tab1"
        expect(tab3).toMatch [[0,1,2], [2,2,1], [1,5,4]]
        filter = database.dense_query
            dims: [0]
            vals: [dv.count()]
            where: (table, row) ->
              table.get("A", row) isnt "a"
          , "tab1"
        expect(filter).toMatch [["a","b","c"], [0,2,1]]

    it "performs (SQL like)filtering queries using where", ->
      inject (database)->
        database.create table, "tab1"
        filter = database.sparse_query
            dims: [0]
            vals: [dv.count()]
            where: (table, row) ->
              table.get("A", row) isnt "a"
          , "tab1"
        expect(filter).toMatch [["b","c"], [2,1]]

  describe 'dbEventMngr',->

    it "executes registered methods on publishing of registered msgs in the msgList", ->
      inject (database,db,dbEventMngr,pubSub,$q)->
        db = new db()
        #creating the sandbox
        dbEventMngr.setSb(pubSub)
        #instantiating the app
        db.init()
        #create a promise
        deferred = $q.defer()
        _data = [table,'test',deferred]
        foo = 
          cb : ->
        spyOn(foo,'cb')
        #subscribing to the outcome msg for 'save table'
        pubSub.subscribe
          msg:'table saved'
          listener:foo.cb
          msgScope:['database']
        #manually publishing the msg 'save table'
        pubSub.publish
          msg:'save table'
          data: _data
          msgScope:['database']
        #expect the eventManager in the database service
        #to process and publish 'table saved' msg  
        expect(foo.cb).toHaveBeenCalled()




