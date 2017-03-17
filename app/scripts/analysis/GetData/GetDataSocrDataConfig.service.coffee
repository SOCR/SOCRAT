'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class GetDataSocrDataConfig extends BaseModuleDataService

  initialize: () ->

    @socrDatasets = [
      name: 'Iris Flower Dataset'
      url: 'datasets/iris.csv'
      description: 'http://wiki.socr.umich.edu/index.php/SOCR_Data_052511_IrisSepalPetalClasses'
    ,
      name: 'consumer_price_index'
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
      name: 'the prices of all companies publically traded at the S&P Stock Exchange(August 2007 - June 2008)'
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