'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: DataWranglerDataAdaptor
  @desc: Reformats data from input table format to the universal DataFrame object
###

module.exports = class DataWranglerDataAdaptor extends BaseService
  @inject 'app_analysis_dataWrangler_msgService'

  initialize: ->
    @eventManager = @app_analysis_dataWrangler_msgService
    @DATA_TYPES = @eventManager.getSupportedDataTypes()

  toCsvString: (dataFrame) ->

    csv = dataFrame.header.toString() + '\n'

    csv += row.toString() + '\n' for row in dataFrame.data

    # remove last carriage return to prevent adding empty row
    csv = csv.slice 0, -1

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

    # remove last empty row
    row.pop() for row in table

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
