'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class GetDataSocrDataConfig extends BaseModuleDataService

  initialize: () ->

    @socrDatasets = [
      name: 'Iris Flower Dataset'
      url: 'datasets/iris.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_052511_IrisSepalPetalClasses'
    ,
    #   name: 'Simulated SOCR Knee Pain Centroid Location Data'
    #   url: 'datasets/knee_pain_data.csv'
    #   description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_KneePainData_041409'
    # ,
    #   name: 'Neuroimaging study of 27 of Global Cortical Surface Curvedness (27 AD, 35 NC and 42 MCI)'
    #   url: 'datasets/Global_Cortical_Surface_Curvedness_AD_NC_MCI.csv'
    #   description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_July2009_ID_NI'
    # ,
    #   name: 'Neuroimaging study of Prefrontal Cortex Volume across Species'
    #   url: 'datasets/Prefrontal_Cortex_Volume_across_Species.csv'
    #   description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_April2009_ID_NI'
    # ,
    #   name: 'Turkiye Student Evaluation Data Set'
    #   url: 'datasets/Turkiye_Student_Evaluation_Data_Set.csv'
    #   description: 'http://wiki.socr.umich.edu/index.php/SOCR_TurkiyeStudentEvalData'
    # ,
    #   name: 'Antarctic Ice Thickness'
    #   url: 'datasets/Antarctic_Ice_Thickness.csv'
    #   description: 'http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_Dinov_042108_Antarctic_IceThicknessMawson'
    # ,
    #   name: 'Baseball Players'
    #   url: 'datasets/Baseball_Players.csv'
    #   description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_MLB_HeightsWeights'
    # ,
    #   name: 'California Ozone'
    #   url: 'datasets/California_Ozone.csv'
    #   description: 'http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_121608_OzoneData'
    # ,
    #   name: 'California Ozone Pollution'
    #   url: 'datasets/California_Ozone_Pollution.csv'
    #   description: 'http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_121608_CA_US_OzoneData'
    # ,
    #   name: 'US Ozone Pollution'
    #   url: 'datasets/US_Ozone_Pollution.csv'
    #   description: 'http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_121608_CA_US_OzoneData'
    # ,
    #   name: 'Countries Rankings'
    #   url: 'datasets/Countries_Rankings.csv'
    #   description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_2008_World_CountriesRankings'
    # ,
      name: 'US Consumer Price Index (1981-2006)'
      url: 'datasets/consumer_price_index.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_Dinov_021808_ConsumerPriceIndex'
    ,
      name: 'US Federal Budget, Income, Expenditures and Deficit Data (1849-2016)'
      url: 'datasets/budgets_deficits.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_US_BudgetsDeficits_1849_2016'
    ,
      name: 'Google Web-Search Trends and Stock Market Data (2005-2011)'
      url: 'datasets/google_trends.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_GoogleTrends_2005_2011'
    ,
      name: 'Wealth of Nations Data (1800-2009)'
      url: 'datasets/wealth_of_nations.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_WealthOfNations_1800_2009'
    ,
      name: 'Standard & Poor Stock Exchange (August 2007 - June 2008)'
      url: 'datasets/standards_poor_500.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_Dinov_070108_SP500_0608'
    ,
      name: 'US Economy by Sector (2002)'
      url: 'datasets/economy2002.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_Dinov_101709_USEconomy'
    ]

  getNames: -> @socrDatasets.map (dataset) ->
    id: dataset.name.toLowerCase()
    name: dataset.name
    desc: dataset.description

  getUrlByName: (datasetId) ->
      (dataset.url for dataset in @socrDatasets when datasetId is dataset.name.toLowerCase()).shift()
