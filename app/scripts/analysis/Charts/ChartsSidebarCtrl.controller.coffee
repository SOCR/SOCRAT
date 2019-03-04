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
    '$timeout',
    '$scope'

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
    @dl = require 'datalib'

    # chart-specific flags (update dictionary as more flags added)
    # general chart parameters

    @chartParams =
      flags:
        # BarChart:
        horizontal: false
        stacked: false
        normalized: false
        threshold: 0
        # BinnedHeatmap:
        yBin: null
        xBin: null
        marginalHistogram: false
        # ScatterPlot:
        showSTDEV: false
        binned: false
        opacity: false
        x_residual: false
        y_residual: false
        # WordCloud:
        startAngle: 0
        endAngle: 90
        orientations: 1
        text: "Input your text"
        # pie chart
        categorical: false
        col: null
      data: null
      labels: null
      graph: null

    @$scope.chartParams =
      flags: {}

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

    # constants
    @yearLowerBound = 1900
    @yearUpperBound = new Date().getFullYear()

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

    @$scope.$watch 'sidebar.chartParams.flags'
    , =>
      @updateDataPoints()
    , true

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

    if @selectedGraph.config.vars.zLabel is "Color"

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
    chartsWithParams = ['Bar Graph', 'Scatter Plot', 'Binned Heatmap', 'Histogram', 'Tukey Box Plot (1.5 IQR)', 'Normal Distribution', 'Ranged Dot Plot', 'Cumulative Frequency']
    if @selectedGraph.name in chartsWithParams
      for param in @selectedGraph.config.params
        @chartParams.flags[param] = @selectedGraph.config.params[param]
      $("#" + id + "Switch").bootstrapSwitch() for id in @selectedGraph.config.params when @selectedGraph.config.params[id] != null

    if @selectedGraph.config.vars.x
      if @selectedGraph.x.includes("date")
        @xCols = []
        colNameCounts = data.header.length
        for nameIndex in [0..colNameCounts - 1]

          randomeTestIndex1 = Math.floor(Math.random() * data.data.length)
          dataValue1 = data.data[randomeTestIndex1][nameIndex]

          randomeTestIndex2 = Math.floor(Math.random() * data.data.length)
          dataValue2 = data.data[randomeTestIndex2][nameIndex]

          randomeTestIndex3 = Math.floor(Math.random() * data.data.length)
          dataValue3 = data.data[randomeTestIndex3][nameIndex]

          checkCount = 0
          for dataValue in [dataValue1, dataValue2, dataValue3]
            if (parseInt(dataValue) or dataValue == 0) and @yearLowerBound < dataValue < @yearUpperBound
              checkCount++
          if checkCount == 3
            @xCols.push data.header[nameIndex]
        else
          @xCols = (col for col, idx in @cols when data.types[idx] in @selectedGraph.config.vars.x)
      @xCol = @xCols[0]

    # trellis chart
    else if @numericalCols.length > 1
      @chosenCols = @numericalCols.slice(0, 2)
      if @categoricalCols.length > 0
        @labelCol = @categoricalCols[0]

    @originalXCols = @xCols

    if @selectedGraph.config.vars.y
      @yCols = []
      for col, idx in @cols when data.types[idx] in @selectedGraph.config.vars.y
        @yCols.push(col)

      if @selectedGraph.name in ['Scatter Plot', 'Histogram']
        @yCols.push("Count")
      # Initialize the y variable
      for yCol in @yCols
        if yCol isnt @xCol
          @yCol = yCol
          break
    @originalYCols = @yCols

    if @selectedGraph.config.vars.z
      @zCols = []
      if @selectedGraph.name isnt 'Treemap' and @selectedGraph.name isnt 'Sunburst'
        @zCols.push("None")
      for col, idx in @cols when data.types[idx] in @selectedGraph.config.vars.z
        # if the variable idx is not in forbiddenVarIdx, put col in zCols list
        if $.inArray(idx, forbiddenVarIdx) is -1
          @zCols.push(col)
      # Initialize the z variable
      @zCol = @zCols[0]
    @originalZCols = @zCols

    chartsWithR = ['Bullet Chart', 'Treemap', 'Sunburst', 'Trellis Chart']
    if @selectedGraph.config.vars.r
      @rCols = []

      if @selectedGraph.name not in chartsWithR
        @rCols.push("None")
      for col, idx in @cols when data.types[idx] in @selectedGraph.config.vars.r
        if $.inArray(idx, forbiddenVarIdx) is -1
          @rCols.push(col)
      # Initialize the z variable
      @rCol = @rCols[0]
    @originalRCols = @rCols

    @$timeout =>
      @updateDataPoints()

  updateDataPoints: (data=@dataFrame) ->

    if @selectedGraph.config.vars
      [xCol, yCol, zCol, rCol] = [@xCol, @yCol, @zCol, @rCol].map (x) -> data.header.indexOf x
      [xType, yType, zType, rType] = [xCol, yCol, zCol, rCol].map (x) -> data.types[x]

    transformed_data = []
    for row in data.data
      obj = {}
      for h, index in data.header
        obj[h] = row[index]
      transformed_data.push obj

    if @selectedGraph.config.vars.x
      # Remove the variables that are already chosen for one field
      # isX is a boolean. This is used to determine if to include 'None' or not
      removeFromList = (variables, list) ->
        newList = []
        if list
          for e in list
            if e == 'None' or $.inArray(e, variables) is -1 # e is not in the chosen variables
              newList.push(e)
        return newList

      @xCols = removeFromList([@yCol], @originalXCols)
      @yCols = removeFromList([@xCol], @originalYCols)

      if xType is 'string'
        @chartParams.flags.categorical = true
        for col, idx in @cols
          if @chartParams.flags.col is null and data.types[idx] in ['number', 'integer']
            @chartParams.flags.col = col
            break
      else
        @chartParams.flags.categorical = false

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

      data = transformed_data

    # if scatter plot matrix
    else if @chosenCols.length > 1
      if @labelCol
        labels = (row[data.header.indexOf(@labelCol)] for row in data.data)
        labels.splice 0, 0, @labelCol
      else labels = null

      chosenIdxs = @chosenCols.map (x) -> data.header.indexOf x
      data = (row.filter((el, idx) -> idx in chosenIdxs) for row in data.data)
      data.splice 0, 0, @chosenCols

    else data = null

    @chartParams.data = data
    @chartParams.labels = labels
    @chartParams.graph = @selectedGraph

    @msgService.broadcast 'charts:updateGraph',
      chartParams: @chartParams
