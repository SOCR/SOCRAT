'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: DatabaseDataAdaptor
  @desc: Reformats data from input table format to the universal DataFrame object
###

module.exports = class DatabaseDataAdaptor extends BaseService
  @inject 'app_analysis_getData_msgService'

  initialize: ->
    @eventManager = @app_analysis_getData_msgService
    @DATA_TYPES = @eventManager.getSupportedDataTypes()

  toDvTable: (dataFrame) ->

    table = []

    # transpose array to make it column oriented
    _data = ((row[i] for row in dataFrame.data) for i in [0...dataFrame.nCols])

    for i, col of _data
      table.push
        name: dataFrame.header[i]
        values: col
        type: 'symbolic'

    table

  toDataFrame: (table) ->

    _nRows = table[0].length
    _nCols = table.length

    # transpose array to make it row oriented
    _data = ((col[i] for col in table) for i in [0..._nRows])

    _header = (col.name for col in table)
    _types = (col.type for col in table)

    dataFrame =
      data: _data
      header: _header
      types: _types
      nRows: _nRows
      nCols: _nCols
      dataType: @DATA_TYPES.FLAT
