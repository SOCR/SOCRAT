###
  Angular wrapper for datavore.js

  app_database module serves as the in-memory database for SOCR framework. The module lets
  you perform create, read, update and delete operations on all the tables created by the
  application.
  
  "database" service is the single point access for all the CRUD operations.To make DB calls
  from another module, publish messages using the "sb" object.
  
  Notes:
    Datavore doesnt have inbuilt event system
    or memory of the tables created using it.
###

db = angular.module 'app_database', []


db.factory 'app_database_constructor', [
  'app_database_manager'
  (manager)->
    (sb)->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'db init called'

      destroy: () ->

      msgList: _msgList
]

db.factory 'app_database_manager',->
  'app_database_dv'
  (database)->
    _sb = null
    _msgList =
          incoming:['create table','get table','delete table'],
          outgoing:['table created','take table','table deleted'],
          scope: ['database']

    _setSb = (sb) ->
      _sb = sb
      database.setSb sb

    _getSb = () ->
      _sb

    _getMsgList = () ->
      _msgList

    getSb: _getSb
    setSb: _setSb
    getMsgList: _getMsgList

db.service 'app_database_dv', ()->

  #contains references to all the tables created.
  _registry = []

  _db = {}
  ###
    @returns {string|boolean}
  ###
  _register = (tname,ref)->
    return false if _registry[tname]?
  		# #name already exists. Create an alternate name.
    #   tname = '_' + tname
    #   _register tname,ref
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
    return false if _registry[tname]?
    #create table
    _ref = dv.table(input)
    # register the reference to the table
    _register(tname,_ref)
    _db

  _db.addColumn = (cname, values, type, iscolumn...,tname)->
    if _registry[tname]?
      _registry[tname].addColumn(cname, values, type, iscolumn)
      manager.sb.send
        'msg' : tname
        'msgScope' : ['database']
      #@todo: Why sending 2 different messages?
      manager.sb.send
        msg: tname+':'+cname
        msgScope:['database']

  _db.removeColumn = (cname,tname)->
    if _registry[tname]?[cname]?
      delete _registry[tname][cname]
      true
    else
      false

  _db.addListener = (opts)->
    if opts?
      if typeof opts is 'function'
        return false
      else
        if opts.table?
          if opts.column?
            msg = opts.table+':'+opts.column
          else
            msg = opts.table
          if _registry[opts.table]?
            #_listeners[table][col] = _listeners[table][col] || []
            #_listeners[table][col].push fn
            manager.sb.send
              'msg' : msg
              'listener': opts.listener
              'msgScope': ['database']


  # destroy any table
  _db.destroy = (tname)->
    if _registry[tname]?
      delete _registry[tname]
      true
    else
      false

  _db.rows = (tname)->
    if _registry[tname]?
      _registry[tname].rows()

  _db.cols = (tname)->
    if _registry[tname]?
      _registry[tname].cols()

  _db.get = (tname,col,row)->
    if _registry[tname]?
      if col?
        if row?
          _registry[tname][col].get row
        else
          _registry[tname][col]
      else
        #TODO : returned object is dv object.
        # need to return only the table content
        _registry[tname]
    else
      false

  _db.exists = (tname)->
    if _registry[tname]?
      true
    else
      false

  # Query methods
  _db.query = (q,name)->
    _db.dense_query(q,name)

  _db.dense_query = (q,tname)->
    if _registry[tname]?
      _registry[tname].dense_query(q)

  _db.sparse_query = (q,tname)->
    if _registry[tname]?
      _registry[tname].sparse_query(q)

  _db.where = (q,tname)->
    if _registry[tname]?
      _registry[tname].where(q)

  _db


db.service 'database',[
  'app_database_dv'
  (_db)->
    #set all the callbacks here.
    _setSb = ((_db) ->
      (sb)->
        #registering database callbacks for all possible incoming messages.
        _methods = [
          {incoming:'save table',outgoing:'table saved',event:_db.create}
          {incoming:'get table',outgoing:'take table',event:_db.get}
        ]
        
        _status = _methods.map (method)->
          sb.subscribe
            msg: method['incoming']
            listener: (msg,data)->
              _data = method.event data

              if _data is false
                if typeof data.promise isnt "undefined"
                  data.promise.reject('table operation failed')
                false
              
              #all publish calls should pass a promise in the data object.
              #if promise is not defined, create one and pass it along.
              
              if typeof data.promise isnt "undefined"
                _data['promise'] = $q.defer()
              else
                _data['promise'] = data.promise

              sb.publish
                msg:'take table'
                data: _data
                msgScope:['database']
            msgScope:['database']

          #console.log(_status)
    )(_db)
    setSb:_setSb
  ]
