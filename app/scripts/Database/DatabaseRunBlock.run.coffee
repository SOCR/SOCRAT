'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name DatabaseRunBlock
  @desc Class for database run block
###

module.exports = class DatabaseRunBlock

  constructor: (@module) ->

  register: ->
    @module.run @getDbRunBlock()

  getDbRunBlock: ->
    # pass the deps
    runBlock = (app_analysis_database_handler) ->
      app_analysis_database_handler.initDb()
      console.log 'db: run block'
    # dependencies for run block
    runBlock.$inject = ['app_analysis_database_handler']
    runBlock


