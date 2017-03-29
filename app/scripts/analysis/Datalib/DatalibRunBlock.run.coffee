'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name DatalibRunBlock
  @desc Class for datalib run block
###

module.exports = class DatalibRunBlock

  constructor: (@module) ->

  register: ->
    @module.run @getDlRunBlock()

  getDlRunBlock: ->
    # pass the deps
    runBlock = (app_analysis_datalib_api) ->
      app_analysis_datalib_api.initDl()
      console.log 'dl: run block'
    # dependencies for run block
    runBlock.$inject = ['app_analysis_datalib_api']
    runBlock


