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


db.factory 'app_database_constructor',[
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

db.factory 'app_database_manager',[
  'app_database_handler'
  (database)->
    _sb = null
    #_msgList =
    #  incoming:['create table','get table','delete table'],
    #  outgoing:['table created','take table','table deleted'],
    #  scope: ['database']

    _msgList =
      incoming:['get table'],
      outgoing:['take table'],
      scope:['database']

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
]

db.service 'app_database_dv', ->

  #contains references to all the tables created.
  _registry = []
  _listeners = {}
  _db = {}
  window._db = _db
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

    if typeof _registry[tname] isnt "undefined" && typeof _listeners[tname] isnt "undefined"
      _table = _listeners[tname]
    else
      return false

    #trigger all listeners attached to the column `name`

    if cname? && typeof _table[cname] isnt "undefined"
      i = 0
      while i < _table[cname].cb.length
        _table[cname].cb[i] _registry[tname][cname] if typeof _table[cname].cb[i] is "function"
        i++

    #trigger all listeners attached to the table.
    #console.log _l?.length
    if _table.cb?.length isnt 0
      i = 0
      while i < _table.cb.length
        _table.cb[i] _registry[tname] if typeof _table.cb[i] is "function"
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
      _registry[tname].addColumn cname, values, type, iscolumn
      #fire away all listeners on the new column.
      _fire tname,cname

  _db.removeColumn = (cname,tname)->
    if _registry[tname]?[cname]?
      #fire away all listeners on the new column.
      _fire tname,cname
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
          _listeners[opts.table] = _listeners[opts.table] || {cb:[]}
          if opts.column?
            _listeners[opts.table][opts.column] = _listeners[opts.table][opts.column] || {cb:[]}
            _listeners[opts.table][opts.column]['cb'].push opts.listener
          else
            _listeners[opts.table]['cb'].push opts.listener
    console.log _listeners[opts.table]

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


db.factory 'app_database_handler',[
  'app_database_dv'
  '$q'
  (_db,$q)->
    console.log "app_database_handler"
    #set all the callbacks here.
    _setSb = (sb)->

      #registering database callbacks for all possible incoming messages.
      _methods = [
        {incoming:'save table',outgoing:'table saved',event:_db.create}
        {incoming:'get table',outgoing:'take table',event:_db.get}
        {incoming:'add listener',outgoing:'listener added',event:_db.addListener}
      ]

      # Creating a test database
      try
        colA = [[1099195200000, 30.802601992077], [1101790800000, 36.331003758254],
        [1104469200000, 43.142498700060], [1107147600000, 40.558263931958],
        [1109566800000, 42.543622385800], [1112245200000, 41.683584710331],
        [1114833600000, 36.375367302328], [1117512000000, 40.719688980730],
        [1120104000000, 43.897963036919], [1122782400000, 49.797033975368],
        [1125460800000, 47.085993935989], [1128052800000, 46.601972859745],
        [1130734800000, 41.567784572762], [1133326800000, 47.296923737245],
        [1136005200000, 47.642969612080], [1138683600000, 50.781515820954],
        [1141102800000, 52.600229204305]]
        colB = [[1025409600000, 0], [1028088000000, -6.3382185140371],
        [1030766400000, -5.9507873460847], [1033358400000, -11.569146943813],
        [1036040400000, -5.4767332317425]]
        colC = [12,3,42,4]
        table = [
          {name:"A", values:colA, type:"numeric"}
          {name:"B", values:colB, type:"numeric"}
        ]
        _db.create table,'charts_test_db'
      catch e
        console.log e.stack
        alert "Error: "+e.message
      #sb.send
      #  msg: tname
      #  msgScope : ['database']
      #@todo: Why sending 2 different messages?
      #sb.send
      #  msg: tname+':'+cname
      #  msgScope:['database']
      _status = _methods.map (method)->
        sb.subscribe
          msg: method['incoming']
          listener: (msg,data)->
            _data = method.event.apply null,data.data
            console.log "Raw data",_data
            if _data is false
              if typeof data.promise isnt "undefined"
                data.promise.reject('table operation failed')
              false
            data.promise.resolve _data
            #all publish calls should pass a promise in the data object.
            #if promise is not defined, create one and pass it along.
            return true
            if typeof data.promise isnt "undefined"
              _data['promise'] = $q.defer()
            else
              _data['promise'] = data.promise

            sb.publish
              msg:'take table'
              data: _data
              msgScope:['database']

          msgScope:['database']

    setSb:_setSb
  ]
