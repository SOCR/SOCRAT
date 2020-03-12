'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class DimensionReductionMainCtrl extends BaseCtrl
  @inject 'app_analysis_dimension_reduction_msgService',
          'app_analysis_dimension_reduction_dataService',
          '$timeout',
          '$scope'

  # all dataSets
  fileSet = ['AlzheimerNeuroimagingData_projector_config.json', 'Antarctic_Ice_Thickness_projector_config.json', 'Baseball_Players_projector_config.json',
              'BiomedBigMetadata_projector_config.json', 'California_Ozone_Pollution_projector_config.json', 'California_Ozone_projector_config.json',
              'Countries_Rankings_projector_config.json', 'Fortune500_projector_config.json', 'HeartAttacks_projector_config.json',
              'SOCR_CountryRanking_projector_config.json', 'SOCR_UKBB_projector_config.json', 'SchizophreniaNeuroimaging_projector_config.json',
              'Turkiye_Student_Evaluation_Data_Set_projector_config.json', 'US_Ozone_Pollution_projector_config.json',
              'iris_projector_config.json', 'knee_pain_data_projector_config.json']

  initialize: ->
    @dataService = @app_analysis_dimension_reduction_dataService
    @msgService = @app_analysis_dimension_reduction_msgService
    @receivedLink = 'https://projector.tensorflow.org/?config=https://raw.githubusercontent.com/SOCR/HTML5_WebSite/master/HTML5/SOCR_TensorBoard_UKBB/data/'
    @receivedLink += fileSet[0]

    @msgService.broadcast 'dimensionReduction:fileSet',
      fileSet: fileSet

    @$scope.$on 'dimensionReduction:link', (event, receivedLink) =>
      @receivedLink = receivedLink
