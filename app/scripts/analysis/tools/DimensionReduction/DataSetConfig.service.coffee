'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class DataSetConfig extends BaseModuleDataService

  initialize: () ->

    @DataSet = [
      name: 'Alzheimer Disease (AD) Case Study Data'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/AlzheimerNeuroimagingData_projector_config.json'
      description: 'http://www.stat.ucla.edu/~dinov/courses_students.dir/04/Spring/Stat233.dir/HWs.dir/AD_NeuroPsychImagingData1.html'
    ,
      name: 'Antarctic Ice Thickness'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/Antarctic_Ice_Thickness_projector_config.json'
      description: 'http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_Dinov_042108_Antarctic_IceThicknessMawson'
    ,
      name: 'Baseball Players'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/Baseball_Players_projector_config.json'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_MLB_HeightsWeights'
    ,
      name: 'Predictive Big Data Analytics, Modeling, Analysis and Visualization of Clinical, Genetic and Imaging Data for Parkinson’s Disease'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/BiomedBigMetadata_projector_config.json'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_PD_BiomedBigMetadata'
    ,
      name: 'California Ozone'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/California_Ozone_projector_config.json'
      description: 'http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_121608_OzoneData'
    ,
      name: 'California Ozone Pollution'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/California_Ozone_Pollution_projector_config.json'
      description: 'http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_121608_CA_US_OzoneData'
    ,
      name: 'Countries Rankings'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/Countries_Rankings_projector_config.json'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_2008_World_CountriesRankings'
    ,
      name: 'CSCD/SOCR Diabetes Case-Study'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/CSCD_SOCR_TensorBoard_Diabetes_projector_config.json'
      description: 'https://umich.instructure.com/courses/38100/files/folder/Case_Studies/21_Diabetes_US_Hospitals_1999_2008'
    ,
      name: 'Neuroimaging study of 27 of Global Cortical Surface Curvedness (27 AD, 35 NC and 42 MCI)'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/Global_Cortical_Surface_Curvedness_AD_NC_MCI_projector_config.json'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_July2009_ID_NI'
    ,
      name: 'Ranking, Revenues and Profits of the Top Fortune500 Companies (1955-2008)'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/Fortune500_projector_config.json'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_Fortune500_1955_2008'
    ,
      name: 'SOCR Heart Attack Data'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/HeartAttacks_projector_config.json'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_AMI_NY_1993_HeartAttacks'
    ,
      name: 'SOCR Country Ranking Data'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/SOCR_CountryRanking_projector_config.json'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_2008_World_CountriesRankings'
    ,
      name: 'SOCR UKBB Tensor Data'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/SOCR_UKBB_projector_config.json'
      description: 'https://www.nature.com/articles/s41598-019-41634-y'
    ,
      name: 'Normal and Schizophrenia Neuroimaging Study of Children'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/SchizophreniaNeuroimaging_projector_config.json'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_Oct2009_ID_NI'
    ,
      name: 'Turkiye Student Evaluation Data Set'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/Turkiye_Student_Evaluation_Data_Set_projector_config.json'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_TurkiyeStudentEvalData'
    ,
      name: 'US Ozone Pollution'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/US_Ozone_Pollution_projector_config.json'
      description: 'http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_121608_CA_US_OzoneData'
    ,
      name: 'Iris Flower Dataset'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/iris_projector_config.json'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_052511_IrisSepalPetalClasses'
    ,
      name: 'Simulated SOCR Knee Pain Centroid Location Data'
      url: 'SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/knee_pain_data_projector_config.json'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_KneePainData_041409'
    ]

  allDataSetsURL: () ->
    'https://projector.tensorflow.org/?config=https://raw.githubusercontent.com/TomWBush/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/allDataSets.json'

  getNames: -> @DataSet.map (dataset) ->
    name: dataset.name
    description: dataset.description

  getURLs: -> @DataSet.map (dataset) ->
    'https://projector.tensorflow.org/?config=https://raw.githubusercontent.com/' + dataset.url

  getUrlByName: (name) ->
    'https://projector.tensorflow.org/?config=https://raw.githubusercontent.com/' + (dataset.url for dataset in @DataSet when name is dataset.name).shift()
