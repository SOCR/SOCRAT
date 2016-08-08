'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: DatabaseNestedStorage
  @desc: Stores non-flat, hierarchical data
###

module.exports = class DatabaseNestedStorage extends BaseService

  initialize: ->
    @nestedObj = null

  save: (obj) ->
    @nestedObj = obj

  get: () ->
    @nestedObj
