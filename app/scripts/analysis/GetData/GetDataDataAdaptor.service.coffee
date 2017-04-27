'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: GetDataDataAdaptor
  @desc: Reformats data from input table format to the universal DataFrame object
###

module.exports = class GetDataDataAdaptor extends BaseService
  @inject 'app_analysis_getData_msgService','app_analysis_getData_dataService'

  initialize: ->
    @eventManager = @app_analysis_getData_msgService
    @dataService = @app_analysis_getData_dataService
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
    arr.every (el) -> typeof el in ['number', 'string']


  isValidDataFrame: (dataFrame) ->
    if dataFrame? and dataFrame.header? and dataFrame.nRows? and dataFrame.nCols? and Array.isArray(dataFrame.data) and dataFrame.purpose?
      true
    else
      false
  
  # accepts handsontable row-oriented table data as input and returns dataFrame
  ###
    @param {Array} tableData - array of objects
    @return {Object} DataFrame
  ###
  toDataFrame: (tableData, header=[]) ->
    if not Array.isArray(tableData) or tableData.length == 0
      throw new Error('invalid dataFrame passed.')
    # by default data types are not known at this step
    #  and should be defined at Clean Data step
    #colTypes = ('symbolic' for [1...tableData.nCols])
        
    if Object.prototype.toString.call(tableData[0]) == "[object Object]"
      header = @getHeaders tableData[0]
      tableData = @extractData tableData
      
    if header.length is 0
      for i in [0...tableData[0]-1]
        header.push(i)

    #generating types for all columns
    tempDF =
        header: header
        nRows: tableData.length
        nCols: header.length
        data: tableData
        dataType: @DATA_TYPES.FLAT
        purpose: 'json' 
    newDataFrame = @transformArraysToObject tempDF
    @dataService.inferTypes newDataFrame
    .then( (typesObj) =>
      dataFrame =
        header: header
        nRows: tableData.length
        nCols: header.length
        data: tableData
        dataType: @DATA_TYPES.FLAT
        types: typesObj.dataFrame.data
        purpose: 'json'  
    )

  ###
    @param dataFrame {Object}
    @param colName {String}
    @return dataFrame {Object}
  ###
  getColValues : (dataFrame, colName) ->
    result = []
    if @isValidDataFrame(dataFrame)? and colName?
      dataFrame.data.forEach (row)->
        result.push row[colName]

      result
    return Object.assign {}, dataFrame, {data:result}

  getHeaders : (data)->
    _col = []
    tree = []

    count = (obj) ->
      try
        if typeof obj is 'object' and obj isnt null
          for key in Object.keys obj
            tree.push key
            count obj[key]
            tree.pop()
        else
          _col.push tree.join('.')
        return _col
      catch e
        console.warn e.message
      return {}

    # generate titles and references
    count data
    return _col
  
  # @TODO : merge this function with jsonToFlatTable.
  extractData: (data)->
    
    if not Array.isArray data
      throw new Error "not a valid array. Cannot extract data"

    parsedData = []
    headers = @getHeaders data[0]
    
    getValue = (path,obj) ->
      if path.split('.').length == 1
        if ( obj[path] == null or obj[path] == undefined ) 
          return null 
        else 
          return obj[path]
      pathTokens = path.split('.')
      newObj = obj[pathTokens.shift()]
      getValue pathTokens.join(), newObj

    data.forEach (el) ->
      result = []
      headers.forEach (columnName)->
        result.push getValue columnName, el
      parsedData.push result

    parsedData

  ###
    @param {Object} dataFrame
  ###
  toTableData: (dataFrame)->

    # TODO: implement for poping up data when coming back from analysis tabs

  # tries to convert JSON to 2d flat data table,
  #  assumes JSON object is not empty - has values,
  #  returns converted data or false if not possible
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
          if (data.every (el) -> Array.isArray el)
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
          if (vals.every (row) -> Array.isArray row) and
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

  enforceTypes: (dataFrame, types=null) ->
    types = types || dataFrame.types
    if types? and dataFrame?    
      Object.keys(types).forEach (type)=>
        dataFrame.data.forEach (dataRow)=>
          switch types[type]
            when "number" then dataRow[type] = parseFloat dataRow[type]

            when "boolean" then dataRow[type] = ( dataRow[type] == 'true')
    dataFrame

  transformArraysToObject: (dataFrame) ->
    # hacking the dataFrame to return Array of Objects
    formattedData = dataFrame.data.map (entry)->
      obj = {}
      dataFrame.header.forEach (h,key)->
        # stats.js lib for a key "indicator.id" checks obj["indicator"]["id"]
        # to fix that, replacing all "." with "_"
        obj[h.replace('.','_')] = entry[key]
      obj 
    return Object.assign {}, dataFrame, {data:formattedData}
