'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: DatalibApiEnumerator
  @desc: Creates API from an arbitrary object
###

module.exports = class DatalibApiBuilder extends BaseService

  initialize: ->

  createApi: (obj) ->
    api = []
    @iterateOverObj obj, api
    api

  iterateOverObj: (obj, methods, stack=[]) ->
    for own key, prop of obj
      if Object.prototype.toString.call(prop) is '[object Function]'
        fullKey = stack + '.' + key
        methods.push fullKey[1..]
      if prop is Object(prop)
        @iterateOverObj prop, methods, fullKey
