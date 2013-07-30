###
  Angular wrapper for datavore.js

  Notes:
    Datavore doesnt have inbuilt event system
    or memory of the tables created using it.
###

db = angular.module "app.db", ["app.mediator"]

db.service "database",[
  "pubSub"
  (pubSub)->
    #contains refrences to all the tables created.
    _registry = []

    _db = {}

    _register = (tname,ref)->
      if _registry[tname]?
    		#name already exists. Create an alternate name.
        tname = "_" + tname
        _register tname,ref
      _registry[tname] = ref
      tname

    _fire = (tname,cname)->
      if _registry[tname]?
        _l = _listeners[tname]
      #trigger all listeners attached to the column `name`
      if cname? && _l[cname]?
        i = 0
        while i < _l[cname].length
          _l[cname][i] _registry[tname].get(cname)
          i++

      #trigger all listeners attached to the table.
      if _l.table.length is not 0
        i = 0
        while i < _l.table.length
          _l.table[i] _registry[tname]
          i++

    _db.create = (input,tname)->
      #create table
      _ref = dv.table(input)
      # register the reference to the table
      _register(tname,_ref)
      _db


    _db.addColumn = (cname, values, type, iscolumn...,tname)->
      if _registry[tname]?
        _registry[tname].addColumn(cname, values, type, iscolumn)
        pubSub.publish
          "msg" : tname
          "msgScope" : ["database"]

    _db.removeColumn = ()->


    _db.addListener = (opts)->
      if opts?
        if typeof opts is "function"
          return false
        else
          if opts.table?
            opts.col = opts.col || ""
            if _registry[opts.table]?
              #_listeners[table][col] = _listeners[table][col] || []
              #_listeners[table][col].push fn
              pubSub.subscribe
                "msg" : opts.table
                "listener": opts.fn
                "msgScope": ["database"]


    # destroy any table
    _db.destroy = (tname)->

    _db.rows = (tname)->

    _db.cols = (tname)->

    _db.get = (col,row,tname)->

    _db.getTable = (tname)->
      _registry[tname]

    _db.dense_query = (q,tname)->

    _db.sparse_query = (q,tname)->

    _db.where = (q,tname)->

    _db
]
