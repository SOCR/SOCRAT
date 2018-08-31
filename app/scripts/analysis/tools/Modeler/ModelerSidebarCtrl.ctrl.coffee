'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ModelerSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_modeler_dataService',
    'app_analysis_modeler_msgService',
    'app_analysis_modeler_dist_list',
    'app_analysis_modeler_getParams',
    '$scope',
    '$timeout'

  initialize: ->
    @dataService = @app_analysis_modeler_dataService
    @msgService = @app_analysis_modeler_msgService
    @distrList = @app_analysis_modeler_dist_list
    @getParams = @app_analysis_modeler_getParams

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
    @labelCol = null

    # choose first distribution as default one
    @distributions = @distrList.getFlat()
    if @distributions.length > 0
      @selectedDistributions = @distributions[0]
      @updateSidebarControls()

    # getting data
    @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        if @dataType isnt obj.dataFrame.dataType
        # update local data type
          #console.log("in get list")
          @dataType = obj.dataFrame.dataType
          # send update to main are actrl
          @msgService.broadcast 'modeler:updateDataType', obj.dataFrame.dataType
        # make local copy of data
        @dataFrame = obj.dataFrame
        # parse dataFrame
        @parseData obj.dataFrame

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
    if data?
      @cols = data.header
      #console.log("selected dist" + @selectedDistributions.name)
      if @selectedDistributions.x
        @xCols = (col for col, idx in @cols when data.types[idx] in @selectedDistributions.x)
        @xCol = @xCols[0]
      @$timeout =>
        @updateDataPoints()

  updateDataPoints: (data=@dataFrame) ->
    [xCol, yCol, zCol] = [@xCol, @yCol, @zCol].map (x) -> data.header.indexOf x
    [xType, yType, zType] = [xCol, yCol, zCol].map (x) -> data.types[x]
    data = ([row[xCol], row[yCol], row[zCol]] for row in data.data)

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
