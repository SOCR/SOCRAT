'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class GetDataSocrDataConfig extends BaseModuleDataService

  initialize: () ->

    @socrDatasets = [
      name: 'Iris Flower Dataset'
      url: 'datasets/iris.csv'
    ,
      name: 'Simulated SOCR Knee Pain Centroid Location Data'
      url: 'datasets/knee_pain_data.csv'
    ,
      name: 'Neuroimaging study of 27 of Global Cortical Surface Curvedness (27 AD, 35 NC and 42 MCI)'
      url: 'datasets/Global_Cortical_Surface_Curvedness_AD_NC_MCI.csv'
    ,
      name: 'Neuroimaging study of Prefrontal Cortex Volume across Species'
      url: 'datasets/Prefrontal_Cortex_Volume_across_Species.csv'
    ,
      name: 'Turkiye Student Evaluation Data Set'
      url: 'datasets/Turkiye_Student_Evaluation_Data_Set.csv'
    ]

  getNames: -> @socrDatasets.map (dataset) ->
    id: dataset.name.toLowerCase()
    name: dataset.name

  getUrlByName: (datasetId) ->
      (dataset.url for dataset in @socrDatasets when datasetId is dataset.name.toLowerCase()).shift()
