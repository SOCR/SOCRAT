'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowerCalcSidebarCtrl extends BaseCtrl
  @inject  'app_analysis_powerCalc_dataService',
  'app_analysis_powerCalc_msgService',
  'app_analysis_powerCalc_algorithms',
  '$scope',
  '$timeout'

  initialize: ->
    # initialing all modules
    @dataService = @app_analysis_powerCalc_dataService
    @msgService = @app_analysis_powerCalc_msgService
    @algorithmsService = @app_analysis_powerCalc_algorithms


    # all alglorithms
    @algorithms = ['Select',
    'Test of One Proportion',
    'Test of Two Proportions',
    'R-square (multiple correlation)',
    'Generic chi-square test',
    'Power of a Simple Poisson Test',
    'Two-sample t test (general case)',
    'One-Sample (or Paired) t Test']
    @selectedAlgorithm = @algorithms[1]

    # set up data and algorithm-agnostic controls
    @DATA_TYPES = @dataService.getDataTypes()
    @dataFrame = null
    @dataType = null
    @numericalCols = []
    @categoricalCols = []
    @subCategoricalCols = []
    @labelCol = ["none"]
    @df = null

    # pre-processed data container
    @container = {} # {name1:[#,#,#,#,#,#....], name2:[#,#,#,#,#,#,#,#.....]}
    @MinMax = [{"min": 0, "max": 1}, {"min": 0, "max": 1}]
    @populations = {}

    # sidebar variables needed to process data
    @newTarget = true
    @curTarget = ["",""]
    @chosenColsOne = null
    @chosenColsTwo = []
    @chosenCats = null
    @chosenSubCatsOne = []
    @chosenSubCatsTwo = []
    @alpha = 0.01
    @thresh = 0
    @thresh1 = 0
    @thresh2 = 0
    @jstat = require('jstat').jStat

    # modes
    @deployed = false
    @threshMode = false
    @threshTypeModes = ["larger", "smaller", "equal"]
    @threshTypeMode = "larger"
    @threshTypeMode1 = "larger"
    @threshTypeMode2 = "larger"
    $("#toggleDataDriven").bootstrapSwitch()
    $("#toggleThresh").bootstrapSwitch()
    $("#twoPropToggleThresh").bootstrapSwitch()
    # data-driven mode toggle
    $("#toggleDataDriven").on 'switchChange.bootstrapSwitch', () =>
      @deployed = !@deployed
      @msgService.broadcast 'powercalc:change_mode',
        deploy: @deployed
    # thresh mode toggle
    $("#toggleThresh").on 'switchChange.bootstrapSwitch', () =>
      @threshMode = !@threshMode
    $("#twoPropToggleThresh").on 'switchChange.bootstrapSwitch', () =>
      @threshMode = !@threshMode

    # initialize slider
    @slider()

    # receive raw data
    @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        if @dataType isnt obj.dataFrame.dataType
          # update local data type
          @dataType = obj.dataFrame.dataType
          # send update to main are actrl
          @msgService.broadcast 'powercalc:updateDataType', obj.dataFrame.dataType
        # make local copy of data
        @dataFrame = obj.dataFrame
        # parse dataFrame
        @df = obj.dataFrame
        @parseData obj.dataFrame
      else
        # TODO: add processing for nested object
        console.log 'NESTED DATASET'

    # receive updated algorithm broadcasted from mainArea
    @$scope.$on 'powercalc:updateAlgorithm_back', (event, data)=>
      @selectedAlgorithm = data

  # Once the algorithm is updated, braodcast to mainArea
  updateAlgControls: () ->
    #broadcast algorithms to main controller
    @msgService.broadcast 'powercalc:updateAlgorithm',
      @selectedAlgorithm
    console.log @jstat.tci(0.53, 0.95, 0.015, 1148)

  # called right after receiving the raw data
  # categorize data types into numeric or names
  # No need to modify this method unless permitted
  parseData: () ->
    @dataService.inferDataTypes @df, (resp) =>
      if resp? and resp.dataFrame? and resp.dataFrame.data?

        #update data types
        for type, idx in @df.types
          @df.types[idx] = resp.dataFrame.data[idx]

        # if the column is numeric, append the header name to @numericalCols
        # if the column is string, append the header name to @categoricalCols
        @numericalCols = []
        @categoricalCols = ["none"]
        id = 0
        for header in @df.types
          if header in ["number", "integer"]
            @numericalCols.push(@df.header[id])
          else if header in ["string"]
            @categoricalCols.push(@df.header[id])
          id += 1

  # called when sidebar updates variables
  # 1. update categories and its subcategories
  # 2. push all the related data into its own category
  update: () ->
    index = @df.header.indexOf(@chosenCats)
    @container = {}
    @subCategoricalCols = []
    for row in @df.data
      if row[index] not of @container
        @container[row[index]] = []

      if row[index] not in @subCategoricalCols
        @subCategoricalCols.push(row[index])

      @container[row[index]].push(row)

  # boradcast data to mainArea once called
  run: () ->
    if (@selectedAlgorithm is 'Two-sample t test (general case)')
      @twoTest()
    else if (@selectedAlgorithm is 'One-Sample (or Paired) t Test')
      @oneTest()
    else if (@selectedAlgorithm is 'Test of One Proportion')
      @oneProp()
    else if (@selectedAlgorithm is 'Test of Two Proportions')
      @twoProp()
    else if (@selectedAlgorithm is 'Generic chi-square test')
      @chiSquare()

  twoTest: ()->
    @populations = {}
    targets = []
    if @chosenColsTwo.length is 1
      $("#twoTestCat").prop("disabled", false)
      $("#twoTestSubCat").prop("disabled", false)
    else
      $("#twoTestCat").prop("disabled", true)
      $("#twoTestSubCat").prop("disabled", true)
      @chosenCats = "none"
      @subCategoricalCols = []

    # compare two different Variables, calculate sepaerately
    if (@chosenCats isnt "none") and (@chosenCats isnt undefined)
      # check num of chosenCol is one
      if @chosenColsTwo.length isnt 1
        return
      # check num of chosenSubCats is two
      if @chosenSubCatsTwo.length isnt 2
        return

      # update comparison targets
      if not @equalList(@curTarget, @chosenSubCatsTwo)
        @curTarget = @chosenSubCatsTwo
        @newTarget = true

      #extract index if col
      index = @df.header.indexOf(@chosenColsTwo[0])

      #extract data from container to population
      for elt in @chosenSubCatsTwo
        @populations[elt] = []
        for row in @container[elt]
          @populations[elt].push(row[index])
      targets = @chosenSubCatsTwo

    else

      if @chosenColsTwo.length isnt 2
        return

      # update comparison targets
      if not @equalList(@curTarget, @chosenColsTwo)
        @curTarget = @chosenColsTwo
        @newTarget = true

      # extract data from data to population
      index1 = @df.header.indexOf(@chosenColsTwo[0])
      index2 = @df.header.indexOf(@chosenColsTwo[1])
      @populations[@chosenColsTwo[0]] = []
      @populations[@chosenColsTwo[1]] = []
      for row in @df.data
        @populations[@chosenColsTwo[0]].push(row[index1])
        @populations[@chosenColsTwo[1]].push(row[index2])
      targets = @chosenColsTwo

    @msgService.broadcast 'powercalc:data',
      popl: @populations
      target: targets


  oneTest: () ->
    @populations = {}
    targets = []
    # if compare two different Variables, calculate separately
    if (@chosenCats isnt "none") and (@chosenCats isnt undefined)

      #extract index if col
      index = @df.header.indexOf(@chosenColsOne)

      if not @equalList(@curTarget, [@chosenSubCatsOne])
        @curTarget = @chosenSubCatsOne
        @newTarget = true

      #extract data from container to population
      @populations[@chosenSubCatsOne] = []
      for row in @container[@chosenSubCatsOne]
        @populations[@chosenSubCatsOne].push(row[index])

      targets = [@chosenSubCatsOne, ""]
    else
      # extract data from data to population
      index1 = @df.header.indexOf(@chosenColsOne)
      @populations[@chosenColsOne] = []
      for row in @df.data
        @populations[@chosenColsOne].push(row[index1])

      targets = [@chosenColsOne, ""]

    @msgService.broadcast 'powercalc:data',
      popl: @populations
      target: targets

  oneProp: () ->
    if @chosenCols is null
        return

    #extract index if col
    index = @df.header.indexOf(@chosenColsOne)
    size = 0

    if index is -1
      return

    # calculate size
    if (@chosenCats is "none") or (@chosenCats is undefined)
      # update comparison target
      if not @equalList([@curTarget], [@chosenColsOne])
        @curTarget = @chosenColsOne
        @newTarget = true

      @findMinMax(@df.data, index, -1, false)

      if @threshMode then size = @runThresh(@df.data, -1, index, -1, false)[0]
      else size = @df.data.length

    else
      # update comparison target
      if not @equalList([@curTarget], [@chosenSubCatsOne])
        @curTarget = @chosenSubCatsOne
        @newTarget = true

      @findMinMax(@container[@chosenSubCatsOne], index, -1, false)
      if @threshMode then size = @runThresh(@container[@chosenSubCatsOne], -1, index, 0, false)[0]
      else size = @container[@chosenSubCatsOne].length

    #calculate
    totalSize = @df.data.length
    if size is 0 then size = 1
    proportion = size/totalSize

    @msgService.broadcast 'powercalc:data',
      prop: proportion
      size: size
      target: @curTarget

  twoProp:() ->
    @populations={}
    size1 = 0
    size2 = 0
    if @chosenColsTwo.length is 1
      $("#twoPropCat").prop("disabled", false)
      $("#twoPropSubCat").prop("disabled", false)
    else
      $("#twoPropCat").prop("disabled", true)
      $("#twoPropSubCat").prop("disabled", true)
      @chosenCats = "none"
      @subCategoricalCols = []

    # calculate size
    if (@chosenCats isnt "none") and (@chosenCats isnt undefined)
      # check num of chosenCol is one
      if @chosenColsTwo.length isnt 1
        return
      # check num of chosenSubCats is two
      if @chosenSubCatsTwo.length isnt 2
        return

      # update comparison targets
      if not @equalList(@curTarget, @chosenSubCatsTwo)
        @curTarget = @chosenSubCatsTwo
        @newTarget = true

      #@findMinMax(@df.data, index, -1, false)

      #extract index if col
      index = @df.header.indexOf(@chosenColsTwo[0])

      #extract data from container to population
      # for elt in @chosenSubCatsTwo
      # 	@populations[elt] = []
      # 	for row in @container[elt]
      # 		@populations[elt].push(row[index])
      @populations[@chosenSubCatsTwo[0]]=[]
      @populations[@chosenSubCatsTwo[1]]=[]
      @MinMax = [
        {"min": Number.MAX_SAFE_INTEGER, "max": Number.MIN_SAFE_INTEGER},
        {"min": Number.MAX_SAFE_INTEGER, "max": Number.MIN_SAFE_INTEGER}
        ]
      for row in @container[@chosenSubCatsTwo[0]]
        @MinMax[0]["min"] = Math.min(@MinMax[0]["min"], row[index])
        @MinMax[0]["max"] = Math.max(@MinMax[0]["max"], row[index])
        @populations[@chosenSubCatsTwo[0]].push(row[index])
      for row in @container[@chosenSubCatsTwo[1]]
        @MinMax[1]["min"] = Math.min(@MinMax[1]["min"], row[index])
        @MinMax[1]["max"] = Math.max(@MinMax[1]["max"], row[index])
        @populations[@chosenSubCatsTwo[1]].push(row[index])

      @slider()

      if @threshMode
        threshes = @runThresh(@container[@chosenSubCatsTwo[0]], @container[@chosenSubCatsTwo[1]], index, index, true)
        size1 = threshes[0]
        size2 = threshes[1]
      else
        size1 = @populations[@chosenSubCatsTwo[0]].length
        size2 = @populations[@chosenSubCatsTwo[1]].length


    else
      # check if the # of chosen cols is 2
      if @chosenColsTwo.length isnt 2
        return


      # check and update comparison targets to avoid recomputation
      if not @equalList(@curTarget, @chosenColsTwo)
        @curTarget = @chosenColsTwo
        @newTarget = true

      # extract data from data to population
      index1 = @df.header.indexOf(@chosenColsTwo[0])
      index2 = @df.header.indexOf(@chosenColsTwo[1])
      @populations[@chosenColsTwo[0]] = []
      @populations[@chosenColsTwo[1]] = []
      @MinMax = [
          {"min": Number.MAX_SAFE_INTEGER, "max": Number.MIN_SAFE_INTEGER},
          {"min": Number.MAX_SAFE_INTEGER, "max": Number.MIN_SAFE_INTEGER}
        ]
      for row in @df.data
        @MinMax[0]["min"] = Math.min(@MinMax[0]["min"], row[index1])
        @MinMax[1]["min"] = Math.min(@MinMax[1]["min"], row[index2])
        @MinMax[0]["max"] = Math.max(@MinMax[0]["max"], row[index1])
        @MinMax[1]["max"] = Math.max(@MinMax[1]["max"], row[index2])
        @populations[@chosenColsTwo[0]].push(row[index1])
        @populations[@chosenColsTwo[1]].push(row[index2])

      @slider()

      if @threshMode
        threshes = @runThresh(@df.data, @df.data, index1, index2, true)
        size1 = threshes[0]
        size2 = threshes[1]
      else
        size1 = @populations[@chosenColsTwo[0]].length
        size2 = @populations[@chosenColsTwo[1]].length

      # console.log size1


    # calculate, avoid dividung by zero
    totalSize = @df.data.length
    if size1 is 0 then size1 = 1
    if size2 is 0 then size2 = 1
    proportion1 = size1/totalSize
    proportion2 = size2/totalSize

    @msgService.broadcast 'powercalc:data',
      prop1: proportion1
      prop2: proportion2
      size1: size1
      size2: size2
      target: @curTarget

  chiSquare:() ->
    @populations = {}
    # check if contains categorical column
    for header in @df.types
      if header in ["string"]
        console.log("Error: Contains categorical column")
        return

    @msgService.broadcast 'powercalc:data',
      data = @df.data


  findMinMax: (data, index1, index2, isTwo) ->
    if @newTarget
      @newTarget = false
      @MinMax = [
        {"min": Number.MAX_SAFE_INTEGER, "max": Number.MIN_SAFE_INTEGER},
        {"min": Number.MAX_SAFE_INTEGER, "max": Number.MIN_SAFE_INTEGER}
      ]
      if isTwo
        # TODO
        return
      else
        for row in data
          i = parseFloat(row[index1])
          if i < @MinMax[0]["min"]
            @MinMax[0]["min"] = i
          if i > @MinMax[0]["max"]
            @MinMax[0]["max"] = i
      @thresh=@MinMax[0]["min"]
    @slider()


  runThresh: (data1, data2, index1, index2, isTwo) ->
    if isTwo
      temp1 = 0
      temp2 = 0
      switch @threshTypeMode1
        when "larger"
          for x in data1
            if parseFloat(x[index1]) > @twoPropThresh1
              temp1 += 1
        when "smaller"
          for x in data1
            if parseFloat(x[index1]) < @twoPropThresh1
              temp1 += 1
        when "equal"
          for x in data1
            if parseFloat(x[index1]) is @twoPropThresh1
              temp1 += 1
      switch @threshTypeMode2
        when "larger"
          for y in data2
            if parseFloat(y[index2]) > @twoPropThresh2
              temp2 += 1
        when "smaller"
          for y in data2
            if parseFloat(y[index2]) < @twoPropThresh2
              temp2 += 1
        when "equal"
          for y in data2
            if parseFloat(y[index2]) is @twoPropThresh2
              temp2 += 1
      return [temp1, temp2]
    else
      temp = 0
      switch @threshTypeMode
        when "larger"
          for x in data1
            if parseFloat(x[index1]) > @thresh
              temp += 1
        when "smaller"
          for x in data1
            if parseFloat(x[index1]) < @thresh
              temp += 1
        when "equal"
          for x in data1
            if parseFloat(x[index1]) is @thresh
              temp += 1
      return [temp]

  slider: ()->

    alphaUI = $("#alphaUI")
    onePropThreshUI = $("#onePropThreshUI")

    alphaUI.slider(
      value: @alpha
      min: 0.001
      max: 0.200
      range: "min"
      step: 0.0001
      slide: (event, ui) =>
        @alpha = ui.value
        @msgService.broadcast 'powercalc:alpha',
          alpha_in: @alpha
        @$scope.$apply()
    )
    onePropThreshUI.slider(
      min: @MinMax[0]["min"]
      max: @MinMax[0]["max"]
      value: @thresh
      range: "min"
      step: 0.1
      slide: (event, ui) =>
        @thresh = ui.value
        @run()
    )
    $("#twoPropThresh1UI").slider(
      min: @MinMax[0]["min"]
      max: @MinMax[0]["max"]
      value: @twoPropThresh1
      orientation: "horizontal"
      range: "min"
      step: 0.1
      slide: (event, ui) =>
        @twoPropThresh1 = ui.value
        @run()
        return
    )
    $("#twoPropThresh2UI").slider(
      min: @MinMax[1]["min"]
      max: @MinMax[1]["max"]
      value: @twoPropThresh2
      orientation: "horizontal"
      range: "min"
      step: 0.1
      slide: (event, ui) =>
        @twoPropThresh2 = ui.value
        @run()
        return
    )

  changeValue: (evt) ->
    name = evt.target.name
    key = evt.which or evt.keyCode
    if key is 13
      @slider()
      @run()
    return

  # compare if list a is same as list b
  # return false when not equal
  equalList: (a, b) ->
    console.log (a.length+ ":"+ b.length)
    if (a.length isnt b.length) then return false
    i = 0
    for item in a
      if b[0] isnt item then return false
      i+=1
    return true
