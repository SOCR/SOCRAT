'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class DimensionReductionSidebarCtrl extends BaseCtrl
  @inject 'app_analysis_dimension_reduction_msgService',
    'app_analysis_dimension_reduction_dataService',
    '$scope',
    '$timeout'

  initialize: ->
    # initializing all modules
    @dataService = @app_analysis_dimension_reduction_dataService
    @msgService = @app_analysis_dimension_reduction_msgService

    # TODO: find a way to bypass same origin, and get the json names from github
    # $.ajax 'https://github.com/SOCR/HTML5_WebSite/tree/master/HTML5/SOCR_TensorBoard_UKBB/data/', {}, (response) -> 
    #   console.log(response)
      
    # url = 'https://github.com/SOCR/HTML5_WebSite/tree/master/HTML5/SOCR_TensorBoard_UKBB/data/'

    # $.ajax(
    #   type: 'GET'
    #   url: url
    #   ).done (o) ->
    #   console.log(o)
    #   return

    # all dataSets
    @fileSets = ['AlzheimerNeuroimagingData_projector_config.json', 'Antarctic_Ice_Thickness_projector_config.json', 'Baseball_Players_projector_config.json',
                 'BiomedBigMetadata_projector_config.json', 'California_Ozone_Pollution_projector_config.json', 'California_Ozone_projector_config.json',
                 'Countries_Rankings_projector_config.json', 'Fortune500_projector_config.json', 'HeartAttacks_projector_config.json',
                 'SOCR_CountryRanking_projector_config.json', 'SOCR_UKBB_projector_config.json', 'SchizophreniaNeuroimaging_projector_config.json',
                 'Turkiye_Student_Evaluation_Data_Set_projector_config.json', 'US_Ozone_Pollution_projector_config.json',
                 'iris_projector_config.json', 'knee_pain_data_projector_config.json']
    @dataSets = new Array()
    @baseLink = 'https://projector.tensorflow.org/?config=https://raw.githubusercontent.com/SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/'
    for name in @fileSets
      tmp = name.split('_projector_config.json')[0]
      # workaround for replace all
      tmp = tmp.split('_').join(' ')
      @dataSets.push(tmp)
    @selectedDataSet = @dataSets[0]
    @link = dateSetNameToLink(@baseLink, @selectedDataSet)

    # Once the dataSet is updated, broadcast new link to mainArea
  updateDataSet: () ->
    #broadcast dataSet to main controller
    @link = dateSetNameToLink(@baseLink, @selectedDataSet)
    @msgService.broadcast 'dimensionReduction:link',
      @link
    console.log(@link)

  # Helper to convert plane dataset name to url for projector
  dateSetNameToLink = (base, name) ->
    return base + name.split(' ').join('_') + '_projector_config.json'
