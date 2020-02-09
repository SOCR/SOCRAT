'use strict'

###
  @name BaseCtrl
  @desc Base class for Angular controllers
###

module.exports = class BaseCtrl

# all dataSets
  @fileSets = ['AlzheimerNeuroimagingData_projector_config.json', 'Antarctic_Ice_Thickness_projector_config.json', 'Baseball_Players_projector_config.json',
              'BiomedBigMetadata_projector_config.json', 'California_Ozone_Pollution_projector_config.json', 'California_Ozone_projector_config.json',
              'Countries_Rankings_projector_config.json', 'Fortune500_projector_config.json', 'HeartAttacks_projector_config.json',
              'SOCR_CountryRanking_projector_config.json', 'SOCR_UKBB_projector_config.json', 'SchizophreniaNeuroimaging_projector_config.json',
              'Turkiye_Student_Evaluation_Data_Set_projector_config.json', 'US_Ozone_Pollution_projector_config.json',
              'iris_projector_config.json', 'knee_pain_data_projector_config.json']

  @register: (module, name) ->
    name ?= @name || @toString().match(/function\s*(.*?)\(/)?[1]
    module.controller name, @

  @inject: (annotations...) ->
    ANNOTATION_REG = /^(\S+)(\s+as\s+(\w+))?$/

    @annotations = annotations.map (annotation) ->
      match = annotation.match(ANNOTATION_REG)
      name: match[1], identifier: match[3] or match[1]

    @$inject = @annotations.map (annotation) -> annotation.name

  constructor: (dependencies...) ->
    if dependencies.length
      for annotation, index in @constructor.annotations
        @[annotation.identifier] = dependencies[index]

      @initialize?()
