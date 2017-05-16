'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: GetDataDataAdaptor
  @desc: Reformats data from input table format to the universal DataFrame object
###

module.exports = class GetDataDataAdaptor extends BaseService
  @inject 'app_analysis_getData_msgService'

  initialize: ->
    @eventManager = @app_analysis_getData_msgService
    @DATA_TYPES = @eventManager.getSupportedDataTypes()

  # https://coffeescript-cookbook.github.io/chapters/arrays/check-type-is-array
  typeIsArray: Array.isArray || ( value ) -> return {}.toString.call(value) is '[object Array]'

  haveSameKeys: (obj1, obj2) ->
    if Object.keys(obj1).length is Object.keys(obj2).length
      res = (k of obj2 for k of obj1)
      res.every (e) -> e is true
    else
      false

  isNumStringArray: (arr) ->
    console.log arr
    arr.every (el) -> typeof el in ['number', 'string']

  # accepts handsontable row-oriented table data as input and returns dataFrame
  toDataFrame: (tableData, header=false) ->

    # by default data types are not known at this step
    #  and should be defined at Clean Data step
#    colTypes = ('symbolic' for [1...tableData.nCols])

    if not header
      header = if tableData.length > 1 then tableData.shift() else []

    dataFrame =
      header: header
      nRows: tableData.length
      nCols: tableData[0].length
      data: tableData
      dataType: @DATA_TYPES.FLAT
      purpose: 'json'

  toHandsontable: ->
    # TODO: implement for poping up data when coming back from analysis tabs

  # tries to convert JSON to 2d flat data table,
  #  assumes JSON object is not empty - has values,
  #  returns coverted data or false if not possible
  jsonToFlatTable: (data) ->
    # check if JSON contains "flat data" - 2d array
    if data? and typeof data is 'object'
      if @typeIsArray data
        # non-empty array
        if not (data.every (el) -> typeof el is 'object')
          # 1d array of strings or numbers
          if (data.every (el) -> typeof el in ['number', 'string'])
            data
        else
          # array of arrays or objects
          if (data.every (el) -> @typeIsArray el)
            # array of arrays
            if (data.every (col) -> col.every (el) -> typeof el in ['number', 'string'])
              # array of arrays of (numbers or strings)
              data
            else
              # non-string values
              false
          else
            # array of arbitrary objects
            # http://stackoverflow.com/a/21266395/1237809
            if (not not data.reduce((prev, next) ->
              # check if objects have same keys
              if @haveSameKeys prev, next
                prevValues = Object.keys(prev).map (k) -> prev[k]
                nextValues = Object.keys(prev).map (k) -> next[k]
                # check that values are numeric/string
                if ((prevValues.length is nextValues.length) and
                  (@isNumStringArray prevValues) and
                  (@isNumStringArray nextValues)
                )
                  next
                else NaN
              else NaN
            ))
              # array of objects with the same keys - make them columns
              cols = Object.keys data[0]
              # reorder values according to keys order
              data = (cols.map((col) -> row[col]) for row in data)
              # insert keys as a header
              data.splice 0, 0, cols
              data
            else
              false
      else
        # arbitrary object
        ks = Object.keys(data)
        vals = ks.map (k) -> data[k]
        if (vals.every (el) -> typeof el in ['number', 'string'])
          # 1d object
          data = [ks, vals]
        else if (vals.every (el) -> typeof el is 'object')
          # object of arrays or objects
          if (vals.every (row) -> @typeIsArray row) and
          (vals.every (row) -> row.every (el) -> typeof el in ['number', 'string'])
            # object of arrays
            vals = (t[i] for t in vals for i of vals)  # transpose
            vals.splice 0, 0, ks  # add header
            vals
          else
            # object of arbitrary objects
          if (not not vals.reduce((prev, next) ->
            # check if objects have same keys
            if @haveSameKeys prev, next
              prevValues = Object.keys(prev).map (k) -> prev[k]
              nextValues = Object.keys(prev).map (k) -> next[k]
              # check that values are
              if ((prevValues.length is nextValues.length) and
                (@isNumStringArray prevValues) and
                (@isNumStringArray nextValues)
              )
                next
              else NaN
            else NaN
          ))
            subKs = Object.keys vals[0]
            data = ([sk].concat(vals.map((val)-> val[sk])) for sk in subKs)
            # insert keys as a header
            data.splice 0, 0, [""].concat ks
            data
        else false