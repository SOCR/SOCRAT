dm = angular.module 'socr.dataModels' ,[
  # 'socr.distributions'
  'socr.statTools'
]

dm.config ->
  console.log 'config block for socr.dataModels'

###
  Base dataModel class.
  Implemented using klass.js.
  All dataModels will be extended from this factory.
###
dm.factory 'dataModelClass', ->
  console.log "zzzzzzzzz"
  c = klass  ->
    _isContinous = null
    _modelType = ''
    _modelX = ''
    _modelY = ''
    _numberOfunatiles = 100
  .methods
    fitCurve:->

    generateSamples: (count)->

    getDescription:->
      "Data Model class"

    getGraphLowerLimit:->

    getGraphUpperLimit:->

    getInstructions:->

    getKSModelTestString:->

    getLowerLimit:->

    getModelCount:->

    getModelType:->

    # return the fitted model values for the x-axis
    returnModelX:->
      _modelX

    returnModelY:->
      _modelY

dm.factory 'binomialDataModel', [
  'dataModelClass'
  #'binomialDistribution'
  'quantileArray'
  (dataModelClass,qa)->
    # remove: once socr.distributions is in place.
    # distributions are directly picked up from core.js
    dist = BinomialDistribution

    binomialDataModelClass = dataModelClass.extend ->
      this.isContinous = true
    .methods
      generateSamples:(count,l,r)->
        samples = []
        dBinomial = new dist l,r
        for i in [0..count] by 1
          samples[i] = dBinomial.simulate()
        samples
 
      fitCurve:(rawData,minx,maxx,rescaleClicked,scaleUp,initReset...,l,r)->
        if estimateParams.isSelected
          dBinomial = new dist rawData
        else
          dBinomial = new dist l,r
        _results.sampleSize = dBinomial.getTrails()
        _results.probablity = dBinomial.getProbability()

        minx = 0
        maxx = dBinomial.getTrails()
        number = SLICE_SIZE
        ind = (maxx - minx)/(number - 2)

        _modelX[0] = minx
        _modelX[number - 1] = maxx
        _modelY[0] = 0
        _modelY[number - 1] = 0

        _modelX[1] = minx
        _modelX[number - 2] = maxx
        _modelY[1] = dBinomial.getDensity minx
        _modelY[number - 2] = dBinomial.getDensity maxx
          
        for i in [2..number-2] by 1
          modelX[i] = minx + ind * i
          modelY[i] = dBinomial.getDensity _modelX[i]

        x = []
        y = []
        temp = []
        #Model Quantiles
        for i in [0..numberOfQuantiles] by 1
          y[i] = dBinomial.getQuantile (i+0.5)/numberOfQuantiles
        #Data Quantiles
        for i in [0..rawDat.length] by 1
          temp[i] = rawDat[i]
          x = analysisUtility.getQuantileArray temp

      getDescription:->
        'Binomial Model Fit'


    b = new binomialDataModelClass()
  ]
