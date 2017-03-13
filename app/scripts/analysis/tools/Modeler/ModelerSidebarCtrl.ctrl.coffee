'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class ModelerSidebarCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService',
    'socrat_analysis_mymodule_msgService',
    '$scope',
    '$timeout'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @msgService = @socrat_analysis_mymodule_msgService
    @distributions = ['Normal', 'Binomial', 'Poisson']

    @DATA_TYPES = @dataService.getDataTypes()

    @selectedDist = null

    # dataset-specific
    @dataFrame = null
    @dataType = null
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
      console.log(obj)
      console.log(obj.dataFrame)
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        if @dataType isnt obj.dataFrame.dataType
        # update local data type
          @dataType = obj.dataFrame.dataType
          # send update to main are actrl
          @msgService.broadcast 'modeler:updateDataType', obj.dataFrame.dataType
        # make local copy of data
        @dataFrame = obj.dataFrame
        # parse dataFrame
        @parseData obj.dataFrame




    if @distributions.length > 0
      @selectedDistributions = @distributions[0]
      @updateDistControls()





  updateDistControls: () ->
    #@algParams = @algorithmsService.getParamsByName @selectedAlgorithm

  parseData: (data) ->
    @dataService.inferDataTypes data, (resp) =>
      if resp and resp.dataFrame and resp.dataFrame.data
        @dataFrame = resp.dataFrame
        @updateSidebarControls()
        @updateDataPoints()

  updateSidebarControls: (data=@dataFrame) ->
     @cols = data.header
#    if @selectedGraph.x
#      @xCols = (col for col, idx in @cols when data.types[idx] in @selectedGraph.x)
#     @xCol = @xCols[0]
#    if @selectedGraph.y
#      @yCols = (col for col, idx in @cols when data.types[idx] in @selectedGraph.y)
#      for yCol in @yCols
#        if yCol isnt @xCol
#          @yCol = yCol
#          break
#    if @selectedGraph.z
#      @zCols = (col for col, idx in @cols when data.types[idx] in @selectedGraph.z)
#      for zCol in @zCols
#        if zCol not in [@xCol, @yCol]
#          @zCol = zCol
#          break
#    @$timeout =>
#      @updateDataPoints()

  updateDataPoints: (data=@dataFrame) ->
    if data
      if @labelCol
        @uniqueLabels =
          num: @uniqueVals (data.header.indexOf(@labelCol) for row in data.data)
          labelCol: @labelCol
      xCol = data.header.indexOf @xCol
      yCol = data.header.indexOf @yCol
      data = ([row[xCol], row[yCol]] for row in data.data)
    @msgService.broadcast 'modeler:updateDataPoints',
      dataPoints: data
      means: means
      labels: labels






