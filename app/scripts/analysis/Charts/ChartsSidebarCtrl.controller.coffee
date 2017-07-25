'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ChartsSidebarCtrl extends BaseCtrl
  @inject '$q',
    '$stateParams',
    'app_analysis_charts_dataTransform',
    'app_analysis_charts_list',
    'app_analysis_charts_sendData',
    'app_analysis_charts_checkTime',
    'app_analysis_charts_dataService',
    'app_analysis_charts_msgService',
    '$timeout'

  initialize: ->
    @msgService = @app_analysis_charts_msgService
    @dataService = @app_analysis_charts_dataService
    @dataTransform = @app_analysis_charts_dataTransform
    @list = @app_analysis_charts_list
    @sendData = @app_analysis_charts_sendData
    @checkTime = @app_analysis_charts_checkTime
    @DATA_TYPES = @dataService.getDataTypes()
    @graphs = []
    @selectedGraph = null
    @maxColors = 10

    # dataset-specific
    @dataFrame = null
    @dataType = null
    @cols = []
    @chosenCols = []
    @numericalCols = []
    @categoricalCols = []
    @xCol = null
    @yCol = null
    @zCol = null
    @rCol = null
    @originalXCols = null
    @originalYCols = null
    @originalZCols = null
    @originalRCols = null
    @labelCol = null

    @stream = false
    @streamColors = [
      name: "blue"
      scheme: ["#045A8D", "#2B8CBE", "#74A9CF", "#A6BDDB", "#D0D1E6", "#F1EEF6"]
    ,
      name: "pink"
      scheme: ["#980043", "#DD1C77", "#DF65B0", "#C994C7", "#D4B9DA", "#F1EEF6"]
    ,
      name: "orange"
      scheme: ["#B30000", "#E34A33", "#FC8D59", "#FDBB84", "#FDD49E", "#FEF0D9"]
    ]

    @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType?
        dataFrame = obj.dataFrame
        switch dataFrame.dataType
          when @DATA_TYPES.FLAT
            @graphs = @list.getFlat()
            @selectedGraph = @graphs[0]
            @dataType = @DATA_TYPES.FLAT
            @parseData dataFrame
            if @checkTime.checkForTime dataFrame.data
              @graphs = @list.getTime()
          when @DATA_TYPES.NESTED
            @graphs = @list.getNested()
            @data = dataFrame.data
            @dataType = @DATA_TYPES.NESTED
            @header = {key: 0, value: "initiate"}

  parseData: (data) ->
    df = data
    @dataService.inferDataTypes data, (resp) =>
      if resp? and resp.dataFrame? and resp.dataFrame.data?
        # update data types with inferred
        for type, idx in df.types
          df.types[idx] = resp.dataFrame.data[idx]
        @dataFrame = df
        @updateSidebarControls(df)
        @updateDataPoints(df)

  uniqueVals: (arr) -> arr.filter (x, i, a) -> i is a.indexOf x

  updateSidebarControls: (data=@dataFrame) ->
    @cols = data.header
    @numericalCols = (col for col, idx in @cols when data.types[idx] in ['integer', 'number'])
    @categoricalCols = (col for col, idx in @cols when data.types[idx] in ['string', 'integer'])
    colData = d3.transpose(data.data)
    @categoricalCols = @categoricalCols.filter (x, i) =>
      @uniqueVals(colData[@cols.indexOf(x)]).length < @maxColors

    # Determine a list of variables that has more than 20 unique values
    # This list will be excluded from zCols if zLabel is color
    forbiddenVarIdx = []
    if @selectedGraph.zLabel is "Color"

      VarForChecking = []
      # VarForChecking only includes the variable idx that has the same
      # data type as Color variable, which defined in ChartsList.service.coffee

      for typeIdx in [0..data.types.length-1] by 1
        if data.types[typeIdx] == 'string' or data.types[typeIdx] == 'integer'
          VarForChecking.push(typeIdx)

      VarForChecking.map((idx) ->
        colorValueSet = new Set()
        for i in [0..data.data.length-1] by 1
          colorValueSet.add(data.data[i][idx])
        if colorValueSet.size > 20
          forbiddenVarIdx.push(idx)
      )
    # end if

    if @selectedGraph.x
      @xCols = (col for col, idx in @cols when data.types[idx] in @selectedGraph.x)
      @xCol = @xCols[0]
    @originalXCols = @xCols

    if @selectedGraph.y
      @yCols = []
      for col, idx in @cols when data.types[idx] in @selectedGraph.y
        @yCols.push(col)
      @yCols.push("None")
      # Initialize the y variable
      for yCol in @yCols
        if yCol isnt @xCol
          @yCol = yCol
          break
    @originalYCols = @yCols

    if @selectedGraph.z
      @zCols = []
      @zCols.push("None")
      for col, idx in @cols when data.types[idx] in @selectedGraph.z
        # if the variable idx is not in forbiddenVarIdx, put col in zCols list
        if $.inArray(idx, forbiddenVarIdx) is -1
          @zCols.push(col)
      # Initialize the z variable
      @zCol = "None"
    @originalZCols = @zCols

    if @selectedGraph.r
      @rCols = []
      @rCols.push("None")
      for col, idx in @cols when data.types[idx] in @selectedGraph.r
        @rCols.push(col)
      # Initialize the z variable
      @rCol = "None"
    @originalRCols = @rCols

    @$timeout =>
      @updateDataPoints()

  updateDataPoints: (data=@dataFrame) ->
    if @selectedGraph.x
      [xCol, yCol, zCol, rCol] = [@xCol, @yCol, @zCol, @rCol].map (x) -> data.header.indexOf x
      [xType, yType, zType, rType] = [xCol, yCol, zCol, rCol].map (x) -> data.types[x]
      data = ([row[xCol], row[yCol], row[zCol], row[rCol]] for row in data.data)

      # Remove the variables that are already chosen for one field
      # isX is a boolean. This is used to determine if to include 'None' or not
      removeFromList = (variables, list) ->
        newList = []
        if list
          for e in list
            if e == 'None' or $.inArray(e, variables) is -1 # e is not in the chosen variables
              newList.push(e)
        return newList

      #@xCols = removeFromList([@yCol, @zCol, @rCol], @originalXCols)
      #@yCols = removeFromList([@xCol, @zCol, @rCol], @originalYCols)
      #@zCols = removeFromList([@xCol, @yCol, @rCol], @originalZCols)
      #@rCols = removeFromList([@xCol, @yCol, @zCol], @originalRCols)

      @xCols = removeFromList([@yCol], @originalXCols)
      @yCols = removeFromList([@xCol], @originalYCols)

      labels =
          xLab:
            value: @xCol
            type: xType
          yLab:
            value: @yCol
            type: yType
          zLab:
            value: @zCol
            type: zType
          rLab:
            value: @rCol
            type: rType

    # if trellis plot
    else if @chosenCols.length > 1
      if @labelCol
        labels = (row[data.header.indexOf(@labelCol)] for row in data.data)
        labels.splice 0, 0, @labelCol
      else labels = null

      chosenIdxs = @chosenCols.map (x) -> data.header.indexOf x
      data = (row.filter((el, idx) -> idx in chosenIdxs) for row in data.data)
      data.splice 0, 0, @chosenCols

    else data = null

    @msgService.broadcast 'charts:updateGraph',
      dataPoints: data
      graph: @selectedGraph
      labels: labels

#  changeGraph: () ->
#    if @graphSelect.name is "Stream Graph"
#      @stream = true
#    else
#      @stream = false

#    if @dataType is "NESTED"
#      @graphInfo.x = "initiate"
#      @sendData.createGraph @data, @graphInfo, {key: 0, value: "initiate"}, @dataType, @selector4.scheme
#    else
#      @sendData.createGraph @chartData, @graphInfo, @headers, @dataType, @selector4.scheme

#  changeVar: (selector, headers, ind) ->
#    console.log @selector4.scheme
    #if scope.graphInfo.graph is one of the time series ones, test variables for time format and only allow those when ind = x
    #only allow numerical ones for ind = y or z
#    for h in headers
#      if selector.value is h.value then @graphInfo[ind] = parseFloat h.key
#    @sendData.createGraph(@chartData, @graphInfo, @headers, @dataType, @selector4.scheme)


