'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class DatabaseHandler extends BaseModuleInitService
  @inject '$q',
    '$timeout',
    'app_analysis_database_dv',
    'app_analysis_database_nestedStorage',
    'app_analysis_database_dataAdaptor',
    'app_analysis_database_msgService'

  initialize: ->
    @eventManager = @app_analysis_database_msgService
    @nestedDb = @app_analysis_database_nestedStorage
    @dataAdaptor = @app_analysis_database_dataAdaptor
    @db = @app_analysis_database_dv

    @DATA_TYPES = null
    @lastDataType = ''

  saveData: (obj) =>
    if obj.dataFrame?
      dataFrame = obj.dataFrame
      # convert from the universal dataFrame object to datavore table or keep as is
      if dataFrame.dataType?
        @lastDataType = dataFrame.dataType
        switch dataFrame.dataType
          when @DATA_TYPES.FLAT
            dvData = @dataAdaptor.toDvTable dataFrame
            res = @db.create dvData, obj.tableName
            res
          when @DATA_TYPES.NESTED
            @nestedDb.save obj.dataFrame.data
            true
          else console.log '%cDATABASE: data type is unknown' , 'color:green'
      else console.log '%cDATABASE: data type is unknown' , 'color:green'
    else console.log '%cDATABASE: nothing to save' , 'color:green'

  getData: (data) =>
    switch @lastDataType
      when @DATA_TYPES.FLAT
        _data = @db.get data.tableName
        # convert data to DataFrame if returning it
        _data = @dataAdaptor.toDataFrame _data
        _data.dataType = @DATA_TYPES.FLAT
        _data
      when @DATA_TYPES.NESTED
        _data = @nestedDb.get()
        _data =
          data: _data
          dataType: @DATA_TYPES.NESTED
      else console.log '%cDATABASE: data type is unknown' , 'color:green'

  setDbListeners: () ->
    # registering database callbacks for all possible incoming messages
    # TODO: add wrapper layer on top of @db methods?
    _methods = [
      incoming: 'save table'
      outgoing: 'table saved'
      event: @saveData
    ,
      incoming: 'get table'
      outgoing: 'take table'
      event: @getData
    ,
      incoming: 'add listener'
      outgoing: 'listener added'
      event: @db.addListener
    ]

    status: _methods.map (method) =>
      @eventManager.subscribe method['incoming'],
        (msg, obj) =>
          console.log "%cDATABASE: listener called for" + msg , "color:green"
          # invoke callback
          _data = method.event.apply null, [obj]

          # all publish calls should pass a promise in the data object
          # if promise is not defined, create one and pass it along
          deferred = obj.promise
          if typeof deferred isnt 'undefined'
            if _data isnt false then deferred.resolve() else deferred.reject()
          else
            _data.promise = $q.defer()

          @eventManager.publish method['outgoing'],
            => console.log '%cDATABASE: listener response: ' + _data, 'color:green'
            _data

  initDb: () ->
    @$timeout =>
      @DATA_TYPES = @eventManager.getSupportedDataTypes()
      @setDbListeners()
