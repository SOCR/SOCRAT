'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ModelerSidebarCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService',
    'socrat_analysis_mymodule_msgService',
    'socrat_analysis_modeler_dist_list',
    'socrat_analysis_modeler_getParams',
    '$scope',
    '$timeout'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @msgService = @socrat_analysis_mymodule_msgService
    @list = @socrat_analysis_modeler_dist_list
    @getParams = @socrat_analysis_modeler_getParams
    #@distributions = ['Normal', 'Binomial', 'Poisson']


    @DATA_TYPES = @dataService.getDataTypes()
    @distributions = []
    @selectedDistributions = null

    # dataset-specific
    @dataFrame = null
    @dataType = null
    @stats = null
    @cols = []
    @chosenCols = []
    @numericalCols = []
    @categoricalCols = []
    @xCol = null
    @yCol = null
    @labelCol = null
    console.log("getting data")
    @dataService.getData().then (obj) =>
      console.log("received data")
      console.log(obj.dataFrame)
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        if @dataType isnt obj.dataFrame.dataType
        # update local data type
          console.log("in get list")
          @dataType = obj.dataFrame.dataType
          @distributions = @list.getFlat()
          console.log(@distributions)
          @selectedDistributions = @distributions[0]
          # send update to main are actrl
          @msgService.broadcast 'modeler:updateDataType', obj.dataFrame.dataType
        # make local copy of data
        @dataFrame = obj.dataFrame
        # parse dataFrame
        @parseData obj.dataFrame




    if @distributions.length > 0
      console.log("in redoing dist")
      @selectedDistributions = @distributions[0]
      @updateDistControls()





  updateDistControls: () ->
    #@algParams = @algorithmsService.getParamsByName @selectedAlgorithm

  parseData: (data) ->
    df = data
    @dataService.inferDataTypes data, (resp) =>
      if resp? and resp.dataFrame? and resp.dataFrame.data?
        for type, idx in df.types
          df.types[idx] = resp.dataFrame.data[idx]
        @dataFrame = df
        @updateSidebarControls(df)
        @updateDataPoints(df)

  updateSidebarControls: (data=@dataFrame) ->
    @cols = data.header
    console.log("selected dist" + @selectedDistributions.name)
    if @selectedDistributions.x
      @xCols = (col for col, idx in @cols when data.types[idx] in @selectedDistributions.x)
      @xCol = @xCols[0]
    if @selectedDistributions.y
      @yCols = (col for col, idx in @cols when data.types[idx] in @selectedDistributions.y)
      for yCol in @yCols
        if yCol isnt @xCol
          @yCol = yCol
          break
    if @selectedDistributions.z
      @zCols = (col for col, idx in @cols when data.types[idx] in @selectedDistributions.z)
      for zCol in @zCols
        if zCol not in [@xCol, @yCol]
          @zCol = zCol
    @$timeout =>
      @updateDataPoints()
  updateDataPoints: (data=@dataFrame) ->
    '''
    if data
      if @labelCol
        @uniqueLabels =
          num: @uniqueVals (data.header.indexOf(@labelCol) for row in data.data)
          labelCol: @labelCol
      xCol = data.header.indexOf @xCol
      yCol = data.header.indexOf @yCol
      data = ([row[xCol], row[yCol]] for row in data.data)



     '''
    console.log("Printing the data" + data)

    [xCol, yCol, zCol] = [@xCol, @yCol, @zCol].map (x) -> data.header.indexOf x
    [xType, yType, zType] = [xCol, yCol, zCol].map (x) -> data.types[x]
    data = ([row[xCol], row[yCol], row[zCol]] for row in data.data)

    console.log("printing stats" + @dataStats)
    @msgService.broadcast 'modeler:updateDataPoints',
      dataPoints: data
      distribution: @selectedDistributions
      labels:
        xLab:
          value: @xCol
          type: xType
        yLab:
          value: @yCol
          type: yType
        zLab:
          value: @zCol
          type: zType








