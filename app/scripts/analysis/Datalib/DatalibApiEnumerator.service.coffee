'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: DatalibApiEnumerator
  @desc: Creates API from an arbitrary object
###

module.exports = class DatalibApiEnumerator extends BaseService

  initialize: ->

  createAPI: (obj) ->
    api = []

  getObjMethods: (obj, stack) ->
#    if obj is Object(obj)
#      for key, method in methods
#        if obj[property] is Object(obj[property])
#          iterateOverObj(obj[property], stack + '.' + property)
#        else
#          props = Object.getOwnPropertyNames(obj)
#          methods = props.filter (x) -> toString.call(x) is '[object Function]'

