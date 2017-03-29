"use strict"

describe "app.db module", ->
  colA = ["a","a","b","b","c"]
  colB = [0,1,2,3,4]
  colC = [12,3,42,4]
  table = [
    {name:"A", values:colA, type:"nominal"}
    {name:"B", values:colB, type:"numeric"}
  ]


  get_table_data =
    tableName:'test_table'

  save_table_data =
    promise:''
    tableName:'test_table'
    dataFrame:
      data:[[1,2],[3,4]]
      header:['firstC','secondC']
      nRows:2
      nCols:2

  beforeEach ->
    module "app_database"
    module "app_mocks"

  describe "database service", ->

    it "creates a table and returned object contains crud API", ->
      inject (app_database_dv)->
        obj = app_database_dv.create table,"test"
        expect(app_database_dv.exists "test").toBeTruthy()
        expect(typeof obj).toEqual "object"
        expect(typeof obj.addColumn).toEqual "function"
        expect(typeof obj.removeColumn).toEqual "function"
        expect(typeof obj.addListener).toEqual "function"
        expect(typeof obj.create).toEqual "function"
        expect(typeof obj.destroy).toEqual "function"

    # TODO: separate updating from creating table in db.coffee
#    it "returns false when table already exists", ->
#      inject (app_database_dv)->
#        app_database_dv.create table,"test"
#        expect(app_database_dv.exists "test").toBeTruthy()
#        expect(app_database_dv.create table,"test").toBeFalsy()

    it "creates table and retrieves a real dataset", ->
      inject (app_database_dv)->
        # 2 columns picked up from http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_AMI_NY_1993_HeartAttacks. Restricted the dataset to 265 rows for brevity.
        _sex = ['F','F','F','F','M','M','F','F','M','F','F','M','F','F','M','M','M','M','F','M','M','F','M','M','M','F','F','M','M','M','M','M','M','M','F','F','F','M','M','F','F','F','F','M','M','M','M','M','F','M','F','M','F','M','M','F','M','F','M','M','M','M','M','M','M','F','F','M','F','F','M','M','M','M','F','F','M','M','F','M','M','M','M','M','M','M','M','M','F','F','M','M','F','M','F','F','M','F','M','F','F','M','F','M','M','M','M','M','M','M','F','M','M','M','F','M','F','F','M','M','F','F','M','F','M','M','M','F','F','M','M','F','F','M','M','M','M','M','M','M','F','M','F','F','F','F','M','F','M','F','M','M','M','M','M','M','M','F','M','F','F','F','M','M','F','M','M','F','F','F','F','M','M','M','M','M','M','F','M','M','M','M','M','M','F','M','F','F','F','M','M','F','M','F','F','F','M','M','F','F','M','M','M','M','F','M','M','M','F','M','M','M','M','M','M','M','F','F','M','F','F','M','M','F','F','M','M','M','M','M','M','M','M','F','M','F','F','F','F','F','M','M','F','M','F','F','M','F','M','F','M','M','M','M','M','M','M','F','M','F','M','M','M','F']
        _died = [0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0]
        _table = [
          {name:"sex",values:_sex,type:"numeric"}
          {name:"died",values:_died,type:"numeric"}
        ]
        app_database_dv.create _table, "heart attack data"
        expect(app_database_dv.get("heart attack data", "sex").length).toEqual 264
        expect(app_database_dv.get("heart attack data", "died").length).toEqual 264
        #getting columns
        expect(app_database_dv.get "heart attack data", "sex").toMatch _sex
        expect(app_database_dv.get "heart attack data", "died").toMatch _died
        #getting whole table
        expect(app_database_dv.get("heart attack data")[0]).toMatch _sex
        expect(app_database_dv.get("heart attack data")[1]).toMatch _died

    it "append column to existing table and read it from the returned obj", ->
      inject (app_database_dv)->
        app_database_dv.create table, "test"
        app_database_dv.addColumn "C", colC, "numeric", "test"
        expect(app_database_dv.get "test", "C").toMatch [12,3,42,4]

    it "remove column from existing table ", ->
      inject (app_database_dv)->
        app_database_dv.create table, "test"
        app_database_dv.removeColumn "B", "test"
        expect(app_database_dv.get "test", "B").not.toBeDefined()
        expect(app_database_dv.get "test", "A").toBeDefined()

    it "returns false if column doesnt exist", ->
      inject (app_database_dv)->
        app_database_dv.create table, "test"
        expect(app_database_dv.removeColumn "B", "test1").toBeFalsy()
        expect(app_database_dv.removeColumn "D", "test").toBeFalsy()

    it "add a listener to a table and trigger with model change", ->
      inject (app_database_dv)->
        app_database_dv.create table, "test"
        foo =
          cb : ->
        spyOn(foo,"cb")
        app_database_dv.addListener
          table : "test"
          listener:foo.cb
        app_database_dv.addColumn "C", colC, "numeric", "test"
        expect(foo.cb).toHaveBeenCalled()

    it "add listeners to a column and trigger with model change", ->
      inject (app_database_dv)->
        app_database_dv.create table, "test"
        foo =
          cb1 : ->
          cb2 : ->
        spyOn(foo,"cb1")
        spyOn(foo,"cb2")
        app_database_dv.addListener
          table : "test"
          column: "C"
          listener:foo.cb1
        app_database_dv.addListener
          table : "test"
          column: "B"
          listener:foo.cb2
        app_database_dv.addColumn "C", colC, "numeric", "test"
        expect(foo.cb1).toHaveBeenCalled()
        expect(foo.cb2).not.toHaveBeenCalled()

    it "destroys a table if it exists", ->
      inject (app_database_dv)->
        app_database_dv.create table, "tab1"
        expect(app_database_dv.destroy "tab1").toBeTruthy()
        expect(app_database_dv.destroy "tab2").toBeFalsy()
        expect(app_database_dv.exists "tab1").toBeFalsy()

    it "append data to column.", ->
      # method doesnt exist yet. Will do this when the method is implemented.

    it "performs (SQL like)filtering queries using where", ->
      inject (app_database_dv)->
        app_database_dv.create table, "tab1"
        tab2 = app_database_dv.where (table,row)->
            table.get("B", row) > 1
          , "tab1"
        expect(tab2[0]).toMatch [1,1,2]
        expect(tab2[1]).toMatch [2,3,4]

    it "performs (SQL like)aggregating queries using query(same as dense_query)", ->
      inject (app_database_dv)->
        app_database_dv.create table, "tab1"
        tab2 = app_database_dv.dense_query
            dims:[0]
            vals:[dv.count(), dv.sum(1)]
          , "tab1"
        expect(tab2).toMatch [["a","b","c"], [2,2,1], [1,5,4]]
        tab3 = app_database_dv.dense_query
            dims:[0]
            vals:[dv.count(), dv.sum(1)]
            code:true
          , "tab1"
        expect(tab3).toMatch [[0,1,2], [2,2,1], [1,5,4]]
        filter = app_database_dv.dense_query
            dims: [0]
            vals: [dv.count()]
            where: (table, row) ->
              table.get("A", row) isnt "a"
          , "tab1"
        expect(filter).toMatch [["a","b","c"], [0,2,1]]

    it "performs (SQL like)filtering queries using where", ->
      inject (app_database_dv)->
        app_database_dv.create table, "tab1"
        filter = app_database_dv.sparse_query
            dims: [0]
            vals: [dv.count()]
            where: (table, row) ->
              table.get("A", row) isnt "a"
          , "tab1"
        expect(filter).toMatch [["b","c"], [2,1]]

          # describe 'dbEventMngr',->

   it "executes listeners on publishing of registered msgs in the msgList", ->
     inject (app_database_manager,app_database_handler,pubSub,$q)->
       #creating the sandbox
       app_database_manager.setSb(pubSub)

       foo =
         cb : ->
       spyOn(foo,'cb')

      #subscribing to the outcome msg for 'save table'
       pubSub.subscribe
         msg:'table saved'
         listener:foo.cb
         msgScope:['database']

       #manually publishing the msg 'save table'
       save_table_data.promise = $q.defer()
       pubSub.publish
         msg:'save table'
         data: save_table_data
         msgScope:['getData']

       #expect the eventManager in the app_database_dv service
       #to process and publish 'table saved' msg
       expect(foo.cb).toHaveBeenCalled()

   it "returns table in dataFrame format",->
     inject (app_database_manager,app_database_handler,pubSub,$q)->
       #creating the sandbox
       app_database_manager.setSb(pubSub)

       #saving data to db.
       save_table_data.promise = $q.defer()
       pubSub.publish
         msg:'save table'
         data: save_table_data
         msgScope:['getData']

       #callback to access data from db
       pubSub.subscribe
         msg:'take table'
         msgScope:['database']
         listener:(msg,tableData)->
           expect(typeof tableData).toEqual('object');
           expect(typeof tableData.data).toEqual('object');
           expect(typeof tableData.header).toEqual('object');
           expect(typeof tableData.nRows).toEqual('number');
           expect(typeof tableData.nCols).toEqual('number');

       #publishing the msg to 'get table'
       pubSub.publish
         msg:'get table'
         data: get_table_data
         msgScope:['getData']

