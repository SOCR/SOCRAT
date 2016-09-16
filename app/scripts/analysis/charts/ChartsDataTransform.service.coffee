'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsDataTransform extends BaseService

  initialize: ->

  transpose: (data) ->
    data[0].map (col, i) -> data.map (row) -> row[i]

  transform: (data) ->
    for col in data
      obj = {}
      for value, i in col
        obj[i] = value
      d3.entries obj

  format: (data) ->
    return @transform @transpose(data)
