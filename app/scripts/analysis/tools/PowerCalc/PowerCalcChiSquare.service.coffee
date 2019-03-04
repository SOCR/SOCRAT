'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_powercalc_chiSquare
  @type: service
  @desc: Performs chiSquare test analysis
###


module.exports = class PowerCalcTwoTGUI extends BaseService
  @inject 'app_analysis_powerCalc_msgService',
    '$timeout'

  initialize: ->

    # dependecies
    @msgService = @app_analysis_powerCalc_msgService
    @name = 'Generic chi-square test'
    @powerCalc = require 'powercalc'

    #variables needed for chisquare
    @chiSquareChi2 = 10
    @chiSquareChi2Max = 20
    @chiSquarePower=0.5
    @chiSquareEffSize = 100
    @chiSquareN=100
    @chiSquareNMax=75
    @chiSquareDf=10
    @chiSquareDfMax = 20
    @chiSquareAlpha=0.05
    @update()

  setAlpha: (alphaIn) ->
    @chiSquareAlpha = alphaIn
    @update()
    return

  saveData: (data) ->
    numRows = data.length
    numCols = data[0].length

    sumRows = []
    sumCols = []
    @chiSquareN = 0
    @chiSquareDf = (numRows-1) * (numCols-1)
    expCount = []

    for i in [0...numRows]
      sumRows.push(0)
      for j in [0...numCols]
        sumRows[i] = sumRows[i] + parseFloat(data[i][j])
        @chiSquareN += parseFloat(data[i][j])

    for i in [0...numCols]
      sumCols.push(0);
      for j in [0...numRows]
        sumCols[i] = sumCols[i] + parseFloat(data[j][i])

    for i in [0...numRows]
      expCount.push([])
      for j in [0...numCols]
        expCount[i][j] = (sumRows[i]*sumCols[j]) / @chiSquareN

    @chiSquareChi2 = 0
    for i in [0...numRows]
      for j in [0...numCols]
        @chiSquareChi2 += Math.pow(parseFloat(data[i][j]) - expCount[i][j], 2) / expCount[i][j]

    @update('chi2')

  getName: () ->
    return @name

  getParams: () ->
    @parameters =
      power: @chiSquarePower
      chi2: @chiSquareChi2
      chi2Max: @chiSquareChi2Max
      effSize: @chiSquareEffSize
      n: @chiSquareN
      nMax: @chiSquareNMax
      df: @chiSquareDf
      dfMax: @chiSquareDfMax


  setParams: (newParams) ->
    @chiSquareChi2 = newParams.chi2
    @chiSquareEffSize = newParams.effSize
    @chiSquareN = newParams.n
    @chiSquareDf = newParams.df
    @update(newParams.target)
    return

  checkRange: () ->
    @chiSquareChi2Max = Math.max(@chiSquareChi2Max, @chiSquareChi2)
    @chiSquareNMax = Math.max(@chiSquareNMax, @chiSquareN)
    @chiSquareDfMax = Math.max(@chiSquareDf, @chiSquareDfMax)
    return

  update: (tar)->
    # update parameters
    if tar is "chi2"
      @chiSquareEffSize = Math.sqrt(@chiSquareChi2/@chiSquareN)
    else if tar is "effSize"
      @chiSquareChi2 = Math.pow(@chiSquareEffSize,2) * @chiSquareN
    else if tar is "n"
      @chiSquareChi2 = Math.pow(@chiSquareEffSize,2) * @chiSquareN

    # update power
    input = 
      chi2: @chiSquareChi2
      proN: @chiSquareEffSize*@chiSquareN
      n: @chiSquareN
      df: @chiSquareDf
      alpha: @chiSquareAlpha
    params = @powerCalc.SimpleChi2GUI_handle(input)
    @chiSquarePower = params.Power
    @checkRange()
