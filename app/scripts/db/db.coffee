###
  Angular wrapper for datavore.js

  Notes:
    Datavore doesnt have inbuilt event system
    or memory of the tables created using it.
###

db = angular.module 'app.db', ['app.mediator']

db.factory 'db', [
  'dbEventMngr'
  (dbEventMngr)->
    (sb)->
      msgList = dbEventMngr.getMsgList()
      dbEventMngr.setSb sb unless !sb?

      init: (opt) ->
        console.log 'db init called'
        dbEventMngr.listenToIncomeEvents()

      destroy: () ->

      msgList: msgList
]
db.service 'dbEventMngr', [
  'database'
  (database)->
    sb = null

    msgList =
      outcome: ['table saved']
      income:
        'save table':
          method: (args...)->
            #table name = projectId:forkId
            tname = args[1]+':'+args[2]
            database.create args[0], tname
          outcome: 'table saved'
        'get table':
          method: database.get
          outcome:null
      scope: ['database']

    eventManager = (msg, data) ->
      try
        #FOR CONSOLE ACCESS#
        window['test'] = database
        _data = msgList.income[msg].method.apply null,data
        #last item in data is a promise. #TODO: need to add a check
        promise = data[data.length - 1]
        promise.resolve _data if _data isnt false
      catch e
        console.log e.message
        promise.reject e.message

      sb.publish
        msg: msgList.income[msg].outcome
        data: _data
        msgScope: msgList.scope

    setSb: (_sb) ->
      return false if _sb is undefined
      sb = _sb

    getMsgList: () ->
      msgList

    listenToIncomeEvents: () ->
      for msg of msgList.income
        console.log 'subscribed for ' + msg
        sb.subscribe
          msg: msg
          listener: eventManager
          msgScope: msgList.scope
          context: console
]

db.service 'database',[
  'pubSub'
  (pubSub)->
    #contains refrences to all the tables created.
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
        pubSub.publish
          'msg' : tname
          'msgScope' : ['database']
        pubSub.publish
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
              pubSub.subscribe
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
]
