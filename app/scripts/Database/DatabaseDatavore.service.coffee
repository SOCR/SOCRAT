'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: DatabaseDatavore
  @desc: Wrapper class for Datavore library
###

module.exports = class DatabaseDatavore extends BaseService

  initialize: ->

    # contains references to all the tables created
    @registry = []
    @listeners = {}
    @db = {}
    @dv = require 'datavore'

  ###
    @returns {string|boolean}
  ###
  register: (tname, ref) ->
    return false if @registry[tname]?
    # #name already exists. Create an alternate name.
    #   tname = '_' + tname
    #   @register tname,ref
    @registry[tname] = ref
    tname

  fire: (tname, cname)->

    if typeof @registry[tname] isnt 'undefined' && typeof @listeners[tname] isnt 'undefined'
      _table = @listeners[tname]
    else
      return false

    #trigger all listeners attached to the column `name`

    if cname? && typeof _table[cname] isnt 'undefined'
      i = 0
      while i < _table[cname].cb.length
        _table[cname].cb[i] @registry[tname][cname] if typeof _table[cname].cb[i] is 'function'
        i++

    #trigger all listeners attached to the table.
    #console.log _l?.length
    if _table.cb?.length isnt 0
      i = 0
      while i < _table.cb.length
        _table.cb[i] @registry[tname] if typeof _table.cb[i] is 'function'
        i++

  create: (input, tname) ->

  # TODO: separate updating from creating
    if @registry[tname]?
      @update input, tname
    else

  # reformat data type
      for col in input
        switch col.type
          when 'numeric' then col.type = @dv.type.numeric
          when 'nominal' then col.type = @dv.type.nominal
          when 'ordinal' then col.type = @dv.type.ordinal
          else col.type = @dv.type.unknown

      # create table
      _ref = @dv.table input
      # register the reference to the table
      @register tname, _ref
      @

  update: (input, tname) ->
  # delete old table
    @destroy tname
    # create new table
    @create input, tname

  addColumn: (cname, values, type, iscolumn..., tname)->
    if @registry[tname]?
      @registry[tname].addColumn cname, values, type, iscolumn
      #fire away all listeners on the new column.

      @fire tname, cname

  removeColumn: (cname, tname) ->
    if @registry[tname]?[cname]?
      #fire away all listeners on the new column.
      @fire tname, cname
      delete @registry[tname][cname]
      true
    else
      false

  addListener: (opts) ->
    if opts?
      if typeof opts is 'function'
        return false
      else
        if opts.table?
          @listeners[opts.table] = @listeners[opts.table] || {cb: []}
          if opts.column?
            @listeners[opts.table][opts.column] = @listeners[opts.table][opts.column] || {cb: []}
            @listeners[opts.table][opts.column]['cb'].push opts.listener
          else
            @listeners[opts.table]['cb'].push opts.listener
    console.log '%cDATABASE:: listeners:', 'color:green'
    console.log @listeners[opts.table]

  # destroy any table
  destroy: (tname) ->
    if @registry[tname]?
      delete @registry[tname]
      true
    else
      false

  rows: (tname) ->
    if @registry[tname]?
      @registry[tname].rows()

  cols: (tname) ->
    if @registry[tname]?
      @registry[tname].cols()

  get: (tname, col, row) ->
    if @registry[tname]?
      if col?
        if row?
          @registry[tname][col].get row
        else
          @registry[tname][col]
      else
        @registry[tname]
    else
      false

  exists: (tname) ->
    if @registry[tname]?
      true
    else
      false

  # Query methods
  query: (q, name) ->
    @dense_query(q, name)

  dense_query: (q, tname) ->
    if @registry[tname]?
      @registry[tname].dense_query(q)

  sparse_query: (q, tname) ->
    if @registry[tname]?
      @registry[tname].sparse_query(q)

  where: (q, tname) ->
    if @registry[tname]?
      @registry[tname].where(q)
