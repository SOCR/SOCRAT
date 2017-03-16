'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class GetDataSocrDataConfig extends BaseModuleDataService

  initialize: () ->

    @socrDatasets = [
      name: 'Iris Flower Dataset'
      url: 'datasets/iris.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_052511_IrisSepalPetalClasses'
    ,
      name: 'Simulated SOCR Knee Pain Centroid Location Data'
      url: 'datasets/knee_pain_data.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_KneePainData_041409'
    ,
      name: 'Neuroimaging study of 27 of Global Cortical Surface Curvedness (27 AD, 35 NC and 42 MCI)'
      url: 'datasets/Global_Cortical_Surface_Curvedness_AD_NC_MCI.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_July2009_ID_NI'
    ,
      name: 'Neuroimaging study of Prefrontal Cortex Volume across Species'
      url: 'datasets/Prefrontal_Cortex_Volume_across_Species.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_April2009_ID_NI'
    ,
      name: 'Turkiye Student Evaluation Data Set'
      url: 'datasets/Turkiye_Student_Evaluation_Data_Set.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_TurkiyeStudentEvalData'
    ,
      name: 'Alzheimer Disease (AD) Case Study Data'
      url: 'datasets/AlzheimerNeuroimagingData.csv'
      description: 'http://www.stat.ucla.edu/~dinov/courses_students.dir/04/Spring/Stat233.dir/HWs.dir/AD_NeuroPsychImagingData1.html'
    ,
      name: 'SOCR Heart Attack Data'
      url: 'datasets/HeartAttacks.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_AMI_NY_1993_HeartAttacks'
    ,
      name: 'Ranking, Revenues and Profits of the Top Fortune500 Companies (1955-2008)'
      url: 'datasets/Fortune500.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_Fortune500_1955_2008'
    ,
      name: 'Neuroimaging Study of Super-resolution Image Enhancing'
      url: 'datasets/NeuroimagingStudyofSuperResolutionImageEnhancing.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_June2008_ID_NI'
    ,
      name: 'Normal and Schizophrenia Neuroimaging Study of Children'
      url: 'datasets/SchizophreniaNeuroimaging.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_Oct2009_ID_NI'
    ,
      name: 'Predictive Big Data Analytics, Modeling, Analysis and Visualization of Clinical, Genetic and Imaging Data for Parkinson’s Disease'
      url: 'datasets/BiomedBigMetadata.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_PD_BiomedBigMetadata'
    ]

  getNames: -> @socrDatasets.map (dataset) ->
    id: dataset.name.toLowerCase()
    name: dataset.name
    desc: dataset.description

  getUrlByName: (datasetId) ->
    (dataset.url for dataset in @socrDatasets when datasetId is dataset.name.toLowerCase()).shift()
