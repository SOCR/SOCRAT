'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: DatalibWrapper
  @desc: Wrapper class for Datalib library
###

module.exports = class DatalibWrapper extends BaseService

  initialize: ->
    @dl = require 'datalib'

  typeInfer: (data, accessor=null) ->
    @dl.type.infer data, accessor

  typeInferAll: (data, accessor=null) ->
    @dl.type.inferAll data, accessor
